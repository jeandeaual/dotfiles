# Usage: write_iso ISO DEVICE
function write_iso --argument-names 'file' 'device' --description "Write an ISO image to a device"
    if test (count $argv) -ne 2
        echo "usage: write_iso ISO DEVICE" 1>&2
        return 1
    end
    if test ! -f $file; or not string match -q "*.iso" -- $file
        echo "The first argument needs to be an ISO file" 1>&2
        return 1
    end
    if test ! -e $device; or not string match -q "/dev/sd*" -- $device
        echo "The second argument needs to be a device" 1>&2
        return 1
    end

    sudo dd if="$file" of="$device" bs=4{{ if eq .chezmoi.os "linux" }}M{{ else }}m{{ end }} conv=fdatasync status=progress
end
