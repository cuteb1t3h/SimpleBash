#!/bin/bash

SUCCESS=0
FAIL=0
COUNTER=0
DIFF_RES=""

declare -a tests=(
    "VAR size grep_test_1.txt"
    "VAR su grep_test_2.txt"
    "VAR for s21_grep.c s21_grep.h Makefile"
    "VAR for s21_grep.c"
    "VAR -e for -e ^int s21_grep.c s21_grep.h Makefile"
    "VAR -e for -e ^int s21_grep.c"
    "VAR -e strlen -e while -f pattern.txt s21_grep.c"
    "VAR -e while -e void -f pattern.txt s21_grep.c Makefile"
)

test_func() {
    t=$(echo $@ | sed "s/VAR/$var/")
    CK_FORK=no valgrind --vgdb=no --leak-check=full --show-leak-kinds=all --track-origins=yes --verbose --log-file=RESULT_VALGRIND.txt ./s21_grep $t > test_s21_grep.log
    leak=$(grep ERROR RESULT_VALGRIND.txt)
    (( COUNTER++ ))
    if [[ $leak == *"ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)"* ]]
        then
          (( SUCCESS++ ))
        echo "$SUCCESS/$FAIL/$COUNTER SUCCESS grep $t"
    else
      (( FAIL++ ))
        echo "$SUCCESS/$FAIL/$COUNTER FAIL grep $t"
    fi
    rm test_s21_grep.log
    rm RESULT_VALGRIND.txt
}

# 1 param
for var1 in i v c l n h s o; do
    for i in "${tests[@]}"; do
        var="-$var1"
        test_func $i
    done
done

# 2 params
for var1 in v c n h i s o; do
    for var2 in v c n h i s o; do
        if [ $var1 != $var2 ]; then
            for i in "${tests[@]}"; do
                var="-$var1 -$var2"
                test_func $i
            done
        fi
    done
done

# 3 params
for var1 in v c n h i s o; do
    for var2 in v c n h i s o; do
        for var3 in v c n h i s o; do
            if [ $var1 != $var2 ] && [ $var2 != $var3 ] && [ $var1 != $var3 ]; then
                for i in "${tests[@]}"; do
                    var="-$var1 -$var2 -$var3"
                    test_func $i
                done
            fi
        done
    done
done

# 2 twin params
for var1 in v c n h i s o; do
    for var2 in v c n h i s o; do
        if [ $var1 != $var2 ]; then
            for i in "${tests[@]}"; do
                var="-$var1$var2"
                test_func $i
            done
        fi
    done
done

# 3 twin params
for var1 in v c n h i s o; do
    for var2 in v c n h i s o; do
        for var3 in v c n h i s o; do
            if [ $var1 != $var2 ] && [ $var2 != $var3 ] && [ $var1 != $var3 ]; then
                for i in "${tests[@]}"; do
                    var="-$var1$var2$var3"
                    test_func $i
                done
            fi
        done
    done
done

echo "SUCCESS: $SUCCESS"
echo "FAIL: $FAIL"
echo "ALL: $COUNTER"
