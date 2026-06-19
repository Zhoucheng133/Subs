import os

def convert_ass_to_utf8(folder_path):
    encodings_to_try = ['gb18030', 'utf-8-sig', 'shift_jis', 'big5', 'utf-16', 'cp1252']
    
    success_count = 0
    fail_count = 0

    print(f"WORK DIR: {folder_path}\n" + "-"*40)

    for root, _, files in os.walk(folder_path):
        for file in files:
            if file.lower().endswith('.ass'):
                file_path = os.path.join(root, file)
                
                content = None
                detected_encoding = None
                
                for enc in encodings_to_try:
                    try:
                        with open(file_path, 'r', encoding=enc) as f:
                            content = f.read()
                        detected_encoding = enc
                        break
                    except (UnicodeDecodeError, LookupError):
                        continue
                
                if content is None:
                    print(f"[Failed] Unkown Encoder: {file}")
                    fail_count += 1
                    continue

                if detected_encoding == 'utf-8-sig' or detected_encoding == 'utf-8':
                    pass

                try:
                    bak_path = file_path + '.bak'
                    if os.path.exists(bak_path):
                        os.remove(bak_path)
                    os.rename(file_path, bak_path)
                    
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(content)
                    
                    print(f"[Success] Converted ({detected_encoding} -> UTF-8): {file}")
                    success_count += 1
                    
                except Exception as e:
                    print(f"[Failed] ERR {file}: {e}")
                    fail_count += 1

    print("-"*40)
    print(f"[Finished]: {success_count} files Converted")

if __name__ == "__main__":
    target_folder = input("Input the folder path: ").strip()
    
    if os.path.isdir(target_folder):
        convert_ass_to_utf8(target_folder)
    else:
        print("Invalid folder path")