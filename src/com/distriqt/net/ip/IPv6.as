/**
 * @author Michael Archbold (https://github.com/marchbold)
 * @created 6/2/2025
 */
package com.distriqt.net.ip
{
	import flash.utils.ByteArray;

	public class IPv6 extends IP
	{
		////////////////////////////////////////////////////////
		//	CONSTANTS
		//

		private static const TAG:String = "IPv6";


		////////////////////////////////////////////////////////
		//	VARIABLES
		//

		private var _zoneId:String;
		public function get zoneId():String { return _zoneId; }


		////////////////////////////////////////////////////////
		//	FUNCTIONALITY
		//

		public function IPv6( ip:String )
		{
			super( ip );
		}


		override public function parse( ip:String ):ByteArray
		{
			var match:Array;
			var result:Object;
			if (ipv6Regexes.deprecatedTransitional.test( ip ))
			{
				match = ipv6Regexes.deprecatedTransitional.exec( ip );
				return parse( "::ffff:" + match[1] );
			}
			else if (ipv6Regexes.native.test( ip ))
			{
				result = expandIPv6( ip, 8 );
				_zoneId = result.zoneId;
				return result.parts;
			}
			else if (ipv6Regexes.transitional.test( ip ))
			{
				match = ipv6Regexes.transitional.exec( ip );
				_zoneId = match[6] || '';
				var addr:String = match[1];
				if (!match[1].endsWith( '::' ))
				{
					addr = addr.slice( 0, -1 );
				}
				result = expandIPv6( addr + (_zoneId == null ? "" : _zoneId), 6 );
				if (result.parts)
				{
					var octets:Array = [
						parseInt( match[2] ),
						parseInt( match[3] ),
						parseInt( match[4] ),
						parseInt( match[5] )
					];
					for (var i:int = 0; i < octets.length; i++)
					{
						var octet:int = octets[i];
						if (!((0 <= octet && octet <= 255)))
						{
							return null;
						}
					}

					result.parts.writeShort( octets[0] << 8 | octets[1] );
					result.parts.writeShort( octets[2] << 8 | octets[3] );
					return result.parts;
				}
			}
			else
			{
				throw new Error( "Invalid IPv6 address" );
			}
			return null;
		}


		/**
		 * Returns the IPv6 address in a normalized string format.
		 *
		 * @return
		 */
		public function toNormalizedString():String
		{
			var result:String = "";
			_bytes.position = 0;
			while (_bytes.bytesAvailable)
			{
				result += _bytes.readUnsignedShort().toString( 16 );
				if (_bytes.bytesAvailable > 0)
				{
					result += ":";
				}
			}
			if (_zoneId)
			{
				result += "%" + _zoneId;
			}
			return result;
		}


		/**
		 * Returns the IPv6 address in a fixed length string format.
		 * eg <code>2001:0db8:0008:0066:0000:0000:0000:0001</code>
		 *
		 * @return
		 */
		override public function toFixedLengthString():String
		{
			var result:String = "";
			_bytes.position = 0;
			while (_bytes.bytesAvailable)
			{
				var part:String = _bytes.readUnsignedShort().toString( 16 );
				result += padPart( part, 4 );
				if (_bytes.bytesAvailable > 0)
				{
					result += ":";
				}
			}
			if (_zoneId)
			{
				result += "%" + _zoneId;
			}
			return result;
		}


		/**
		 * Returns the IPv6 address in a compressed string format.
		 * eg <code>2001:db8:8:66::1</code>
		 *
		 * @return
		 */
		override public function toString():String
		{
			var regex:RegExp = /((^|:)(0(:|$)){2,})/g;
			var string:String = toNormalizedString();
			var bestMatchIndex:int = 0;
			var bestMatchLength:int = -1;
			var lastIndex:int = 0;
			var matches:Array = regex.exec( string );
			for (var i:int = 1; i < matches.length; i++)
			{
				var match:String = matches[i];
				lastIndex = string.indexOf( match, lastIndex );
				if (match.length > bestMatchLength)
				{
					bestMatchIndex = lastIndex;
					bestMatchLength = match.length;
				}
			}
			return string.substring( 0, bestMatchIndex ) + "::" + string.substring( bestMatchIndex + bestMatchLength );
		}


		////////////////////////////////////////////////////////
		//	INTERNALS
		//


		private function expandIPv6( string:String, expectedParts:int ):Object
		{
			var zoneId:String = null;
			var result:ByteArray = new ByteArray();
			if (string.indexOf( '::' ) !== string.lastIndexOf( '::' ))
			{
				throw new Error( "Invalid IPv6 address" );
			}
			var colonCount:int = 0;
			var lastColon:int = -1;
			if (ipv6Regexes.zoneIndex.test( string ))
			{
				var z:Array = ipv6Regexes.zoneIndex.exec( string );
				if (z.length > 1)
				{
					zoneId = z[1];
					string = string.replace( /%.+$/, '' );
				}
			}

			while ((lastColon = string.indexOf( ':', lastColon + 1 )) >= 0)
			{
				colonCount++;
			}
			if (string.substr( 0, 2 ) === '::')
			{
				colonCount--;
			}
			if (string.substr( -2, 2 ) === '::')
			{
				colonCount--;
			}

			if (colonCount > expectedParts)
			{
				throw new Error( "Invalid IPv6 address: invalid colon count" );
			}

			var replacementCount:int = expectedParts - colonCount;
			var replacement:String = ':';
			while (replacementCount--)
			{
				replacement += '0:';
			}

			// Insert the missing zeroes
			string = string.replace( '::', replacement );

			if (string.charAt( 0 ) == ':')
			{
				string = string.slice( 1 );
			}

			if (string.charAt( string.length - 1 ) == ':')
			{
				string = string.slice( 0, -1 );
			}

			var parts:Array = string.split( ':' );
			for (var i:int = 0; i < parts.length; i++)
			{
				var part:String = parts[i];
				if (part.length == 0)
				{
					result.writeShort( 0 );
				}
				else
				{
					result.writeShort( parseInt( part, 16 ) );
				}
			}

			return {
				parts : result,
				zoneId: zoneId
			};
		}


	}
}
