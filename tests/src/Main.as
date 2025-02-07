package
{
	import com.distriqt.net.ip.IP;
	import com.distriqt.net.ip.IPRangeCheck;
	import com.distriqt.net.ip.IPv4;
	import com.distriqt.net.ip.IPv6;

	import flash.display.Sprite;

	public class Main extends Sprite
	{
		public function Main()
		{

			assertEqual( "192.168.1.10", new IPv4( "192.168.1.10" ).toString() )
			assertEqual( "192.168.0.1", new IPv4( "192.168.1" ).toString() )
			assertEqual( "192.0.0.168", new IPv4( "192.168" ).toString() )
			assertEqual( "0.0.0.192", new IPv4( "192" ).toString() )
			assertEqual( "192.168.1.1", new IPv4( "3232235777" ).toString() )
			assertEqual( "192.168.1.1", new IPv4( "030052000401" ).toString() )
			assertEqual( "192.168.1.1", new IPv4( "0xc0.168.1.1" ).toString() )
			assertEqual( "192.168.1.1", new IPv4( "192.0250.1.1" ).toString() )
			assertEqual( "192.168.1.1", new IPv4( "0xc0a80101" ).toString() )
			assertEqual( "127.42.1.2", new IPv4( "127.42.258" ).toString() )
			assertEqual( "127.1.2.3", new IPv4( "127.66051" ).toString() )
			assertEqual( "10.1.1.255", new IPv4( "10.1.1.0xff" ).toString() )

			assertEqual( true, IP.process( "192.168.1.10" ) is IPv4 )
			assertEqual( false, IP.process( "192.168.1.10" ) is IPv6 )

			assertThrows( function ():void
						  {
							  IP.process( "10.0.0.wtf" );
						  } );
			assertThrows( function ():void
						  {
							  IP.process( "8.0x1ffffff" );
						  } );
			assertThrows( function ():void
						  {
							  IP.process( "8.8.0x1ffff" );
						  } );
			assertThrows( function ():void
						  {
							  IP.process( "10.048.1.1" );
						  } );


			assertEqual( "2001:db8:85a3:0:0:8a2e:370:7334", new IPv6( "2001:0db8:85a3:0000:0000:8a2e:0370:7334" ).toNormalizedString() )
			assertEqual( "2001:0db8:85a3:0000:0000:8a2e:0370:7334", new IPv6( "2001:0db8:85a3:0000:0000:8a2e:0370:7334" ).toFixedLengthString() )
			assertEqual( "0:0:0:0:0:ffff:c0a8:101", new IPv6( "::ffff:192.168.1.1" ).toNormalizedString() );
			assertEqual( "::ffff:c0a8:101", new IPv6( "::ffff:192.168.1.1" ).toString() );


			// ipv4

			// should fail when the IP is not in the range
			assertEqual( false, IPRangeCheck.check( "102.1.5.0", "102.1.5.1" ) );

			// should succeed when the IP is in the range
			assertEqual( true, IPRangeCheck.check( "102.1.5.0", "102.1.5.0" ) );
			assertEqual( true, IPRangeCheck.check( "102.1.5.92", "102.1.5.0/24" ) );
			assertEqual( true, IPRangeCheck.check( "192.168.1.1", [ "102.1.5.0/24", "192.168.1.0/24" ] ) );

			//
//			assetEqual( true, IPRangeCheck.check( "0:0:0:0:0:FFFF:222.1.41.90", "222.1.41.90" ) );
//			assetEqual( true, IPRangeCheck.check( "0:0:0:0:0:FFFF:222.1.41.90", "222.1.41.0/24" ) );

			// should fail when comparing IPv6 with IPv4
			assertEqual( false, IPRangeCheck.check( "::5", "102.1.1.2" ) );
			assertEqual( false, IPRangeCheck.check( "::5", "102.1.1.2" ) );
			assertEqual( false, IPRangeCheck.check( "195.58.1.62", "::1/128" ) );


			// ipv6

			// should fail when the IP is not in the range
			assertEqual( false, IPRangeCheck.check( "::1", "::2/128" ) );
			assertEqual( false, IPRangeCheck.check( "::1", [ "::2", "::3/128" ] ) );

			// should succeed when the IP is in the range
			assertEqual( true, IPRangeCheck.check( "::1", "::1" ) );
			assertEqual( true, IPRangeCheck.check( "::1", [ "::1" ] ) );
			assertEqual( true, IPRangeCheck.check( "2001:cdba::3257:9652", "2001:cdba::3257:9652/128" ) );

			// an array of the same CIDRs should be the same as one CIDR string
			assertEqual( IPRangeCheck.check( "::1", "::1" ), IPRangeCheck.check( "::1", [ "::1", "::1", "::1" ] ) );

			// should handle IPv6 synonyms
			assertEqual( true, IPRangeCheck.check( "2001:cdba:0000:0000:0000:0000:3257:9652", "2001:cdba:0:0:0:0:3257:9652" ) );
			assertEqual( true, IPRangeCheck.check( "2001:cdba:0000:0000:0000:0000:3257:9652", "2001:cdba::3257:9652" ) );
			assertEqual( true, IPRangeCheck.check( "2001:cdba:0:0:0:0:3257:9652", "2001:cdba:0000:0000:0000:0000:3257:9652/128" ) );


			trace( "SUCCESS" );
		}


		public function assertEqual( a:*, b:* ):void
		{
			if (a != b)
			{
				throw new Error( "Test failed" );
			}
		}


		public function assertThrows( func:Function ):void
		{
			try
			{
				func();
				throw new Error( "Test failed" );
			}
			catch (e:Error)
			{
			}
		}


	}
}
