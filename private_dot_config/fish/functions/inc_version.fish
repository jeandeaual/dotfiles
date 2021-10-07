# Usage:
# echo "1.2.3" | inc_version 3
# 1.2.4
# echo "1.2.3" | inc_version 2
# 1.3.0
# echo "1.2.3" | inc_version 1
# 2.0.0
function inc_version --argument-names 'version' --description "Increment a version number"
    awk -F. -vOFS=. '{ $ver++; while(ver++<NF) $ver=0; print $0 }' ver="$version"
end
