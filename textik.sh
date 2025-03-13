#!/bin/bash

# Проверка на наличие аргумента (имя файла)
if [ $# -ne 1 ]; then
    echo "Использование: $0 <имя_файла>"
    exit 1
fi

input_file=$1  # Теперь используем правильную переменную
filename_without_extension="${input_file%.*}"  # Извлекаем имя без расширения
file_extension="${input_file##*.}"  # Получаем расширение файла
output_mp3="${filename_without_extension}.mp3"
output_txt="${filename_without_extension}_transcription.txt"

# Функция для конвертации видео в аудио
convert_video_to_audio() {
    ffmpeg -i "$1" -vn -acodec mp3 "$2"
    echo "Конвертация завершена: $2"
}

# Функция для разбиения аудио на части (по 30 минут)
split_audio() {
    mkdir -p audio_parts
    ffmpeg -i "$1" -f segment -segment_time 1800 -c copy audio_parts/"${filename_without_extension}_part_%03d.mp3"
    echo "Аудио разделено на части в директории audio_parts"
}

# Функция для транскрибации и сохранения в текстовый файл
transcribe_audio() {
    whisper "$1" --model medium --output_dir ./transcriptions
    echo "Транскрибация завершена для $1"
}

# Очистка существующего файла с результатами
> "$output_txt"

# Конвертация видео в аудио
convert_video_to_audio "$input_file" "$output_mp3"

# Разбиение аудио на части
split_audio "$output_mp3"

# Транскрибация каждой части аудио и сохранение результата в текстовый файл
for part in audio_parts/*.mp3; do
    echo "Транскрибируем $part..."
    transcribe_audio "$part"
    
    # Добавление результатов транскрибации в итоговый текстовый файл
    for txt_file in ./transcriptions/*.txt; do
        cat "$txt_file" >> "$output_txt"
        rm "$txt_file"  # Удаление временного текстового файла
    done
done

# Очистка временных файлов
rm -rf audio_parts transcriptions

echo "Процесс завершён. Результаты транскрибации сохранены в $output_txt."
