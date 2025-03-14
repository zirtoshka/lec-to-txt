#!/bin/bash

# Проверка на наличие аргумента (имя файла)
if [ $# -ne 1 ]; then
    echo "Использование: $0 <имя_файла.mp4>"
    exit 1
fi

# Входной файл
input_file=$1

# Извлекаем имя файла без расширения
filename_without_extension="${input_file%.*}"

mkdir "${filename_without_extension}"
cd "${filename_without_extension}"
# Конвертация .mp4 в .mp3
echo "Конвертируем $input_file в MP3..."
ffmpeg -i ../"$input_file" -vn -acodec mp3 "${filename_without_extension}.mp3"

# Транскрибация с помощью Whisper и сохранение в текстовый файл
echo "Запускаем транскрибацию для ${filename_without_extension}.mp3..."
whisper "${filename_without_extension}.mp3" --model medium --output_dir . > "${filename_without_extension}.txt"

echo "Форматируем транскрипт..."
sed -E 's/^\[.*\] *//g' "${filename_without_extension}.txt" > "${filename_without_extension}_formatted.txt"

echo "Удаляем временные файлы..."
find . -type f ! -name "${filename_without_extension}.mp3" ! -name "${filename_without_extension}.txt" ! -name "${filename_without_extension}_formatted.txt" -exec rm -f {} \;

echo "Процесс завершён. Результаты транскрибации сохранены в ${filename_without_extension}.txt."
