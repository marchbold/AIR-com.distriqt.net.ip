/**
 * @author Michael Archbold (https://github.com/marchbold)
 * @created 6/2/2025
 */
package com.distriqt.net.ip
{
	public class CIDRRange
	{
		////////////////////////////////////////////////////////
		//	CONSTANTS
		//

		private static const TAG:String = "CIDRRange";


		////////////////////////////////////////////////////////
		//	VARIABLES
		//

		private var _source:String;
		private var _network:IP;
		private var _mask:int;


		////////////////////////////////////////////////////////
		//	FUNCTIONALITY
		//

		public function CIDRRange( cidr:String )
		{
			this._source = cidr;
			var parts:Array = cidr.split( "/" );
			if (parts.length != 2)
			{
				throw new Error( "Invalid CIDR range" );
			}
			this._network = IP.process( parts[0] );
			this._mask = int( parts[1] );
		}


		public function contains( ip:IP ):Boolean
		{
			if (_network.isIPv6 != ip.isIPv6) return false;
			ip.bytes.position = 0;
			_network.bytes.position = 0;
			for (var i:int = 1; i <= (ip.isIPv6 ? 16 : 4); i++)
			{
				var ipBit:uint = ip.bytes.readUnsignedByte();
				var ipBitMask:uint = (ipBit & (255 << (8 * i - this._mask)));
				var networkBit:uint = _network.bytes.readUnsignedByte();
				var networkBitMasked:uint = (networkBit & (255 << (8 * i - this._mask)));
				if (ipBitMask != networkBitMasked) return false;
			}
			return true;
		}


		public static function isValidCIDR( cidr:String ):Boolean
		{
			try
			{
				new CIDRRange( cidr );
				return true;
			}
			catch (e:Error)
			{
			}
			return false;
		}


	}
}
