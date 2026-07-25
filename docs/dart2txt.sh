#!/bin/bash

# ==========================================
# フォルダ下のdartファイルを、1つのtextファイルにまとめるプログラム
# ==========================================

# ==========================================
# 1. 出力ファイルの初期化（中身を空にする）
# ==========================================
> all_souses.txt
> all_tests.txt

# ==========================================
# 2. lib ディレクトリの処理 (all_souses.txt へ)
# ==========================================
find ../lib/ -name "*.txt" -o -name "*.dart" | while read -r file; do
  echo "// ==========================================" >> all_souses.txt
  echo "// FILE_PATH: $file" >> all_souses.txt
  echo "// ==========================================" >> all_souses.txt
  cat "$file" >> all_souses.txt
  echo "" >> all_souses.txt
done

# ==========================================
# 3. test ディレクトリの処理 (all_tests.txt へ)
# ==========================================
find ../test/ -name "*.txt" -o -name "*.dart" | while read -r file; do
  echo "// ==========================================" >> all_tests.txt
  echo "// FILE_PATH: $file" >> all_tests.txt
  echo "// ==========================================" >> all_tests.txt
  cat "$file" >> all_tests.txt
  echo "" >> all_tests.txt
done
