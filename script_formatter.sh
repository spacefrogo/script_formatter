#!/bin/bash

if [ "$#" -eq 0 ] || [ "$#" -lt 0 ]; then
    exit 0
fi

# --help
print_help ()
{
    printf -- 'Usage: script_formatter.sh in [-h] [-s] [-i nb_char] [-e]';
    printf -- ' [-o out]\n\n\t in\t\t\t\tinputfile\n\t-h, --header\t\t\thead';
    printf -- 'er generation\n\t-s, --spaces\t\t\tforce spaces instead of tabulations for';
    printf -- ' indentation\n\t-i, --indentation=nb_char\tnumber of charac';
    printf -- 'ters for indentation (8 by default)\n\t-e, --expand\t\t\tfo';
    printf -- 'rce do and then keywords on new lines\n\t-o, --output=out';
    printf -- '\t\toutput file (stdout by default)\n';
    exit 0;
}

original="$1"
var1="copy"
cp "./$original" "./$var1"

# check if file exists
if [[ ! -r "$var1" || ! -f "$var1" || ! -s "$var1" ]]; then
    rm "$var1"
    exit -1
fi

# FUNCTIONS

#SHEBANG
do_shebang()
{
    comperator=0
    var2=$(head -n 1 $var1)
    shebang="#!/bin/bash\n"
    shebang2="#!/bin/bash\n"
    checkvar2=$(head --bytes 2 "$var1")
    compare="#!"

    if [ "$checkvar2" == "$compare" ]; then
        len=${#var2}
        final=${var2:2}
        if [ ! -x "$final" ]; then
            sed -i "1d" "$var1"
            sed -i "1i $shebang2" "$var1"
        fi
    else
        sed -i "1i $shebang" "$var1"
    fi
}

# HEADER
add_header()
{
    varline=$(sed -n '/#/,/#/p' $1 | wc -l)
    let "varline--"
    let "varline--"
    d="d"
    final1="${varline}${d}"
    test1="2,$final1"
    varDate=$(date -r $var1 +%F)

    #  sed -i "$test1" "$1"
    sed -i '3i #################' "$var1"
    sed -i "4i#  $original               " "$var1"
    sed -i "5i #\n" "$var1"
    sed -i "6i#      "  "$var1"
    sed -i "7i # \"$varDate\"" "$var1"
    sed -i '8d' "$var1"
    sed -i '9i #################' "$var1"
}

# MANDATORY PARTS HERE
# add shebang
do_shebang
#fix brackets

while read line; do

    if [[ $line == *['{']* ]]; then
        count=$(echo $line | wc -c)
        last_char="$(echo -n $line | tail -c 1)"
        first_char="$(echo $line | head -c1)"
        
        if [ $first_char == '{' ];  then
            count_first=$(echo $line | wc -c)
            if [ $count_first -ge 2 ]; then
                line_first=$(grep -n "$line" "$1"| cut -d: -f 1)
                 echo "is $line_first"
                 the_first=" $line_first s/{/{\n/g"
                 sed -i "$the_first" "$1" 2>/dev/null
            fi         
        fi
        
        if [ $last_char == '{' ]; then
            if [ $count -ge 2 ]; then
                number_line=$(grep -n "$line" "$1"| cut -d: -f 1)
                 the=" $number_line s/{/\n{/g"
                 sed -i "$the" "$1" 2>/dev/null
            fi
        fi
        
        if [ $first_char != '{' ]; then
            if  [ $last_char != '{' ]; then
                middle_line=$(grep -n "$line" "$1"| cut -d: -f 1)
                the_middle=" $middle_line s/{/\n{\n/g"
                sed -i "$the_middle" "$1" 2>/dev/null
            fi
        fi
    fi
done <"$1"

while read line; do

    if [[ $line == *['}']* ]]; then
        count_close=$(echo $line | wc -c)
        last_char_close="$(echo -n $line | tail -c 1)"
        first_char_close="$(echo $line | head -c1)"

        if [ $first_char_close == '}' ];  then
            count_first_close=$(echo $line | wc -c)
            if [ $count_first_close -ge 2 ]; then
                line_first_close=$(grep -n "$line" "$1"| cut -d: -f 1)
                the_first_close=" $line_first_close s/}/}\n/g"
                sed -i "$the_first_close" "$1" 2>/dev/null
            fi
        fi
        
        if [ $last_char_close == '}' ]; then
            if [ $count_close -ge 2 ]; then
                number_line_close=$(grep -n "$line" "$1"| cut -d: -f 1)
                the_close=" $number_line_close s/}/\n}/g"
                sed -i "$the_close" "$1" 2>/dev/null
            fi
        fi
        
        if [ $first_char_close != '}' ]; then
            if  [ $last_char_close != '}' ]; then
                middle_line_close=$(grep -n "$line" "$1"| cut -d: -f 1)
                the_middle_close=" $middle_line_close s/}/\n}\n/g"
                sed -i "$the_middle_close" "$1" 2>/dev/null
                
            fi
        fi
    fi
done <"$1"
#brackets end

#do and then
#do

sed -i -e '$a\' "$1"

while read line; do
    SUB='do'
    SUB_middle='; do'
    first_char_do=$(cut -c-2 <<< "$line")
    last_char_do=${line:(-4)}
    
    if [[ $first_char_do != "$SUB" ]]; then
        if [[ $last_char_do != "$SUB_middle" ]]; then
            middle_line_do=$(grep -n "$line" "$1"| cut -d: -f 1)
            the_middle_do=" $middle_line_do s/$SUB_middle/\n$SUB\n/g"
            sed -i "$the_middle_do" "$1" 2>/dev/null
        fi
    fi

    if [[ "$first_char_do" == *"$SUB"* ]];  then
        count_first=$(echo $line | wc -c)
        if [ $count_first -ge 3 ]; then
            line_second_first=$(grep -n "^$line" "$1"| cut -d: -f 1)
            the_first_do=" $line_second_first s/$SUB/$SUB\n/g"
            sed -i "$the_first_do" "$1" 2>/dev/null
        fi
    fi

    if [[ "$line" == *"$SUB"* ]]; then
        if [[ "$last_char_do" == *"$SUB_middle"* ]];  then
            line_second=$(grep -n "$line" "$1"| cut -d: -f 1)
            the_first=" $line_second s/$SUB_middle/\n$SUB/g"
            sed -i "$the_first" "$1" 2>/dev/null
        fi
    fi
    
done <"$1"

#then
while read line; do
    SUB='then'
    SUB_middle='; then'
    
    first_char_do=$(cut -c-2 <<< "$line")
    last_char_do=${line:(-6)}
    
    if [[ $first_char_do != "$SUB" ]]; then
        if [[ $last_char_do != "$SUB_middle" ]]; then
            middle_line_do=$(grep -n "$line" "$1"| cut -d: -f 1)
            the_middle_do=" $middle_line_do s/$SUB_middle/\n$SUB\n/g"
            sed -i "$the_middle_do" "$1" 2>/dev/null
        fi
    fi
    
    
    if [[ "$first_char_do" == *"$SUB"* ]];  then
        count_first=$(echo $line | wc -c)
        if [ $count_first -ge 5 ]; then
            line_second_first=$(grep -n "^$line" "$1"| cut -d: -f 1)
            the_first_do=" $line_second_first s/$SUB/$SUB\n/g"
            sed -i "$the_first_do" "$1" 2>/dev/null
        fi
    fi
    
    if [[ "$line" == *"$SUB"* ]]; then
        if [[ "$last_char_do" == *"$SUB_middle"* ]];  then
            line_second=$(grep -n "$line" "$1"| cut -d: -f 1)
            the_first=" $line_second s/$SUB_middle/\n$SUB/g"
            sed -i "$the_first" "$1" 2>/dev/null
        fi
        
    fi
done <"$1"

# add default identation
expand="expand -t 8 \"\$0\" > /tmp/e && mv /tmp/e \"\$0\""
find . -name $var1 ! -type d -exec bash -c "$expand" {} \;

# MANDATORY PARTS END HERE

if [ "$#" -eq 1 ]; then    
    file="`cat $var1`"
    echo "$file"
    rm "$var1"
    exit 0
fi

var2=$2
export header=0
export identation=8
export output=""
options=$(getopt -l "header,spaces,identation:,expand,output:" -o "hsi:eo:" -a -- "$@")

eval set -- "$options"

while true
do   
    case $1 in
        -h|--header)
            header=1
            break;;
        -s|--spaces)
            break;;
        -i|--identation)
            shift
            export identation=$1
            break;;
        -e|--expand)
            break;;
        -o|--output)
            shift
            export output=$1
            break;;
        --)
            shift
            ;;
        *)
            print_help
            break;;
    esac
    shift
done

if test $header -eq 1; then
   add_header "$var1"
fi

expand="expand -t $identation \"\$0\" > /tmp/e && mv /tmp/e \"\$0\""
find . -name $var1 ! -type d -exec bash -c "$expand" {} \;

sed -i 's|}|& \n|' "$var1"

file="`cat $var1`"
echo "$file"
rm "$var1"
exit 0
