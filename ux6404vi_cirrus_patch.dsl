DefinitionBlock ("", "SSDT", 3, "CUSTOM", "CSC3551", 0x01072009)
{
    External (_SB.PC00.SPI1, DeviceObj)
    External (_SB.PC00.SPI1.SPK1, DeviceObj)

    Scope (_SB.PC00.SPI1.SPK1)
    {
        Name (_DSD, Package ()
        {
            ToUUID ("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
            Package ()
            {
                Package () { "cirrus,dev-index", Package () { Zero, One }},
                Package () { "reset-gpios", Package () {
		            SPK1, One, Zero, Zero,
		            SPK1, One, Zero, Zero
                } },
                Package () { "spk-id-gpios", Package () {
                    SPK1, 0x02, Zero, Zero,
                    SPK1, 0x02, Zero, Zero
                } },
                Package () { "cirrus,speaker-position",		Package () { Zero, One } },
                Package () { "cirrus,gpio1-func",			Package () { One, One } },
                Package () { "cirrus,gpio2-func",			Package () { 0x02, 0x02 } },
                Package () { "cirrus,boost-type",			Package () { One, One } }
            }
        })
    }

    Scope (_SB.PC00.SPI1)
    {
        Name (_DSD, Package ()
        {
            ToUUID ("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
            Package ()
            {
                Package () { "cs-gpios", Package () {
                    Zero,                    // Native CS
                    SPK1, Zero, Zero, Zero   // GPIO CS
                } }
            }
        })
    }
}
