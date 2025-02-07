/**
 * @author Michael Archbold (https://github.com/marchbold)
 * @created 6/2/2025
 */
package com.distriqt.net.ip
{
	public class IPRangeCheck
	{
		////////////////////////////////////////////////////////
		//	CONSTANTS
		//

		private static const TAG:String = "IPRangeCheck";


		////////////////////////////////////////////////////////
		//	VARIABLES
		//


		////////////////////////////////////////////////////////
		//	FUNCTIONALITY
		//

		/**
		 * Check if the specified address is in the specified range
		 *
		 * @param addr  The address to check
		 * @param range The range to check against. This can be a single CIDR range or an array of CIDR ranges
		 * @return
		 */
		public static function check( addr:String, range:* ):Boolean
		{
			if (range is String)
			{
				return checkSingleCIDR( addr, String( range ) );
			}
			else if (range is Array)
			{
				for each (var cidr:String in range)
				{
					if (checkSingleCIDR( addr, cidr ))
					{
						return true;
					}
				}
			}
			return false;
		}


		private static function checkSingleCIDR( addr:String, cidr:String ):Boolean
		{
			try
			{
				var parsedAddr:IP = IP.process( addr );
				if (CIDRRange.isValidCIDR( cidr ))
				{
					var parsedRange:CIDRRange = new CIDRRange( cidr );
					return parsedRange.contains( parsedAddr );
				}
				else
				{
					// Try as an IP address
					var parsedCIDRAsIP:IP = IP.process( cidr );
					return parsedAddr.equals( parsedCIDRAsIP );
				}
			}
			catch (e:Error)
			{
				return false;
			}
		}

	}
}
