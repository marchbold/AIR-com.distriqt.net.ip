/**
 * @author Michael Archbold (https://github.com/marchbold)
 * @created 6/2/2025
 */
package com.distriqt.net.ip
{
	import flash.utils.ByteArray;

	/**
	 *
	 */
	public class IP
	{
		////////////////////////////////////////////////////////
		//	CONSTANTS
		//

		private static const TAG:String = "IPv4";

		// A list of regular expressions that match arbitrary IPv4 addresses,
		// for which a number of weird notations exist.
		// Note that an address like 0010.0xa5.1.1 is considered legal.
		protected static const ipv4Part:Object = '(0?\\d+|0x[a-f0-9]+)';
		protected static const ipv4Regexes:Object = {
			fourOctet : new RegExp( "^" + ipv4Part + "\\." + ipv4Part + "\\." + ipv4Part + "\\." + ipv4Part + "$", 'i' ),
			threeOctet: new RegExp( "^" + ipv4Part + "\\." + ipv4Part + "\\." + ipv4Part + "$", 'i' ),
			twoOctet  : new RegExp( "^" + ipv4Part + "\\." + ipv4Part + "$", 'i' ),
			longValue : new RegExp( "^" + ipv4Part + "$", 'i' )
		};

		protected static const octalRegex:RegExp = new RegExp( "^0[0-7]+$", 'i' );
		protected static const hexRegex:RegExp = new RegExp( "^0x[a-f0-9]+$", 'i' );

		protected static const zoneIndex:String = '%[0-9a-z]{1,}';

		// IPv6-matching regular expressions.
		// For IPv6, the task is simpler: it is enough to match the colon-delimited
		// hexadecimal IPv6 and a transitional variant with dotted-decimal IPv4 at
		// the end.
		protected static const ipv6Part:String = '(?:[0-9a-f]+::?)+';
		protected static const ipv6Regexes:Object = {
			zoneIndex             : new RegExp( zoneIndex, 'i' ),
			native                : new RegExp( "^(::)?(" + ipv6Part + ")?([0-9a-f]+)?(::)?(" + zoneIndex + ")?$", 'i' ),
			deprecatedTransitional: new RegExp( "^(?:::)(" + ipv4Part + "\\." + ipv4Part + "\\." + ipv4Part + "\\." + ipv4Part + "(" + zoneIndex + ")?)$", 'i' ),
			transitional          : new RegExp( "^((?:" + ipv6Part + ")|(?:::)(?:" + ipv6Part + ")?)" + ipv4Part + "\\." + ipv4Part + "\\." + ipv4Part + "\\." + ipv4Part + "(" + zoneIndex + ")?$", 'i' )
		};


		/**
		 * Process the specified IP address and return the appropriate IPv4 or IPv6 instance
		 *
		 * @param ip The IP address to parse
		 * @return IPv4 or IPv6 instance
		 * @throws Error if the IP address is invalid
		 */
		public static function process( ip:String ):IP
		{
			if (ipv4Regexes.fourOctet.test( ip )
					|| ipv4Regexes.twoOctet.test( ip )
					|| ipv4Regexes.threeOctet.test( ip )
					|| ipv4Regexes.longValue.test( ip )
			)
			{
				return new IPv4( ip );
			}
			else if (ipv6Regexes.native.test( ip )
					|| ipv6Regexes.deprecatedTransitional.test( ip )
					|| ipv6Regexes.transitional.test( ip )
			)
			{
				return new IPv6( ip );
			}
			else
			{
				throw new Error( "Invalid IP address" );
			}
		}


		////////////////////////////////////////////////////////
		//	VARIABLES
		//

		protected var _source:String;
		public function get source():String { return _source; }

		protected var _bytes:ByteArray;
		public function get bytes():ByteArray { return _bytes; }


		////////////////////////////////////////////////////////
		//	FUNCTIONALITY
		//

		public function IP( ip:String )
		{
			_source = trim( ip ).toLowerCase();
			_bytes = parse( _source );
		}


		public function parse( ip:String ):ByteArray
		{
			throw new Error( "Not implemented" );
		}


		public function equals( other:IP ):Boolean
		{
			return this.toFixedLengthString() == other.toFixedLengthString();
		}


		public function toString():String
		{
			return _source;
		}


		public function toFixedLengthString():String
		{
			return _source;
		}


		public static function isIPv4( ip:String ):Boolean
		{
			return IP.process( ip ) is IPv4;
		}


		public static function isIPv6( ip:String ):Boolean
		{
			return IP.process( ip ) is IPv6;
		}


		public function get isIPv4():Boolean
		{
			return this is IPv4;
		}


		public function get isIPv6():Boolean
		{
			return this is IPv6;
		}


		//
		//	HELPERS
		//

		private static function trim( s:String ):String
		{
			return s.replace( /^\s*|\s*$/gim, "" );
		}


		protected static function parseIntAuto( string ):uint
		{
			// Hexadedimal base 16 (0x#)
			if (hexRegex.test( string ))
			{
				return parseInt( string, 16 );
			}
			// While octal representation is discouraged by ECMAScript 3
			// and forbidden by ECMAScript 5, we silently allow it to
			// work only if the rest of the string has numbers less than 8.
			if (string.charAt( 0 ) === '0' && !isNaN( parseInt( string.charAt( 1 ), 10 ) ))
			{
				if (octalRegex.test( string ))
				{
					return parseInt( string, 8 );
				}
				throw new Error( "ipaddr: cannot parse " + string + " as octal" );
			}
			// Always include the base 10 radix!
			return parseInt( string, 10 );
		}


		protected function padPart( part:String, length:int ):String
		{
			while (part.length < length)
			{
				part = "0" + part;
			}
			return part;
		}

	}
}
