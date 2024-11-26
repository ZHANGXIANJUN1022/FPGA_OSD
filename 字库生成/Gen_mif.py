input_file_path = "D:\\work\\Work\\project_document\\OSD\\字库生成\\unicode.txt"
# 输出 MIF 文件路径
mif_file_path = "D:\\work\\Work\\project_document\\OSD\\字库生成\\unicode_1616.mif"

# 处理文件并生成 MIF 文件
word_len = 2; #若是16*16的字体，word_len 等于2 ，32*32则是4，以此类推
 # 读取输入文件
with open(input_file_path, 'r', encoding='utf-8') as file:
    lines = file.readlines()
    
binary_lines = []    # 存储二进制结果

for line in lines:
    line = line.strip()
    if "/*" not in line: 
        # 提取十六进制数
        hex_numbers = [num.strip() for num in line.split(",") if num.strip().startswith("0x")]
        # 按 word_len 处理成指定宽度的二进制数
        for i in range(0, len(hex_numbers), word_len):  # 每次取 group_size 个十六进制数
            hex_group = hex_numbers[i:i + word_len]
            if len(hex_group) == word_len:  # 确保数据量满足一组
                # 拼接二进制
                binary_data = ''.join(bin(int(h, 16))[2:].zfill(8) for h in hex_group)
                binary_lines.append(binary_data)
        

# 写入 MIF 文件
width = word_len * 8  # 每行数据宽度
depth = len(binary_lines)  # 数据深度

with open(mif_file_path, 'w', encoding='utf-8') as mif_file:
    #mif_file.write("-- Memory Initialization File\n")
    mif_file.write(f"WIDTH={width};\n")  # 每行数据宽度
    mif_file.write(f"DEPTH={depth};\n\n")  # 深度取决于二进制数据行数
    mif_file.write("ADDRESS_RADIX=HEX;\n")  # 地址格式为十六进制
    mif_file.write("DATA_RADIX=BIN;\n\n")  # 数据格式为二进制
    mif_file.write("CONTENT BEGIN\n")
        
    for idx, binary in enumerate(binary_lines):
        mif_file.write(f"    {idx:04X} : {binary};\n")  # 地址为 4 位十六进制，数据为二进制
        
    mif_file.write("END;\n")

print(f"MIF 文件已生成: {mif_file_path}")