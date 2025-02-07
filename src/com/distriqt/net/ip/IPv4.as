/**
 * @author Michael Archbold (https://github.com/marchbold)
 * @created 6/2/2025
 */
package com.distriqt.net.ip
{
	import flash.utils.ByteArray;

	public class IPv4 extends IP
	{
		////////////////////////////////////////////////////////
		//	CONSTANTS
		//

		private static const TAG:String = "IPv4";


		////////////////////////////////////////////////////////
		//	VARIABLES
		//


		////////////////////////////////////////////////////////
		//	FUNCTIONALITY
		//

		public function IPv4( ip:String )
		{
			super( ip );
		}


		override public function parse( ip:String ):ByteArray
		{
			var result:ByteArray = new ByteArray();
			var match:Array;
			var ref:Array;
			var value:uint;
			if (ipv4Regexes.fourOctet.test( ip ))
			{
				match = ipv4Regexes.fourOctet.exec( ip );
				ref = match.slice( 1, 6 );
				for (var i:int = 0; i < ref.length; i++)
				{
					result.writeByte( parseIntAuto( ref[i] ) );
				}
			}
			else if (ipv4Regexes.longValue.test( ip ))
			{
				match = ipv4Regexes.longValue.exec( ip );
				value = parseIntAuto( match[1] );
				if (value > 0xffffffff || value < 0)
				{
					throw new Error( 'ip address outside defined range' );
				}
				for (var shift:int = 24; shift >= 0; shift -= 8)
				{
					result.writeByte( (value >> shift) & 0xff );
				}
			}
			else if (ipv4Regexes.threeOctet.test( ip ))
			{
				match = ipv4Regexes.threeOctet.exec( ip );
				ref = match.slice( 1, 5 );
				value = parseIntAuto( ref[2] );
				if (value > 0xffff || value < 0)
				{
					throw new Error( 'ip address outside defined range' );
				}
				result.writeByte( parseIntAuto( ref[0] ) );
				result.writeByte( parseIntAuto( ref[1] ) );
				result.writeByte( (value >> 8) & 0xff );
				result.writeByte( value & 0xff );
			}
			else if (ipv4Regexes.twoOctet.test( ip ))
			{
				match = ipv4Regexes.twoOctet.exec( ip );
				ref = match.slice( 1, 4 );
				value = parseIntAuto( ref[1] );
				if (value > 0xffffff || value < 0)
				{
					throw new Error( 'ip address outside defined range' );
				}
				result.writeByte( parseIntAuto( ref[0] ) );
				result.writeByte( (value >> 16) & 0xff );
				result.writeByte( (value >> 8) & 0xff );
				result.writeByte( value & 0xff );
			}
			else
			{
				throw new Error( "Invalid IPv4 address" );
			}
			return result;
		}


		/**
		 * Returns the IPv4 address in a normalized string format.
		 *
		 * @return
		 */
		override public function toString():String
		{
			var result:String = "";
			_bytes.position = 0;
			while (_bytes.bytesAvailable)
			{
				result += _bytes.readUnsignedByte();
				if (_bytes.bytesAvailable > 0)
				{
					result += ".";
				}
			}
			return result;
		}


		/**
		 * Returns the IPv4 address in a fixed length string format.
		 *
		 * @return
		 */
		override public function toFixedLengthString():String
		{
			var result:String = "";
			_bytes.position = 0;
			while (_bytes.bytesAvailable)
			{
				result += padPart( _bytes.readUnsignedByte().toString(), 3 );
				if (_bytes.bytesAvailable > 0)
				{
					result += ".";
				}
			}
			return result;
		}


	}
}
