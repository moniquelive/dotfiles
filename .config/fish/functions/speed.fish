function speed
    while true
        printf "Speed testing... "
        set -l j (speedtest -s 18102 -f json)
        set -l ds (math (echo $j | jq '.download.bandwidth') \* 8e-6)
        set -l us (math (echo $j | jq '.upload.bandwidth') \* 8e-6)
        date
        printf "Download: %s, Upload: %s\n" $ds $us
        if test $ds -lt 100
            printf "Restarting network... "
            sudo networksetup -setnetworkserviceenabled Ethernet off
            sleep 10
            sudo networksetup -setnetworkserviceenabled Ethernet on
            sudo nextdns restart
            echo Done
        end
        sleep 300
        echo ---
    end
end
