# Put the name of the zone here you wish to update.  This can also be a
# subdomain underneath your zone i.e. yourpc.example.dynv6.net
:global ddnsdomain "example.dynv6.com"

# Put the name of the key here as shown in the keys manager under dynv6.com
:global ddnskeyname "_123._tsig.dynv6.com"

# Put the key secret here.  Please keep this confidental since this secret is
# used to authenticate update queries.  Make sure that the key's associated
# hashing algorithm is md5 since this is the only algorithm supported by RouterOS.
:global ddnskeysecret "YourKEYsecret=="

{
    :local result [ /tool fetch url="http://ipinfo.io/ip" as-value output=user ]
    :if ($result->"status" = "finished") do={
        :local wanip [ :toip [ :pick ($result->"data") 0 ( [ :len ($result->"data") ] - 1 ) ] ]
        :local ddnsip [ :resolve $ddnsdomain ]

        :log info ("dynv6: current = $wanip")
        :log info ("dynv6: actual = $ddnsip")

        # [ :resolve dynv6.com ] \
        if ($ddnsip != $wanip) do={
            :log info ("dynv6: updating $ddnsdomain")
            /tool dns-update \
                dns-server=[ :resolve "dynv6.com" ] \
                zone=$ddnsdomain \
                key-name=$ddnskeyname \
                key=$ddnskeysecret \
                address=$wanip
        }
    }
}
