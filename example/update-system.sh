#!/usr/bin/env bash

# 检查是否以root用户运行
if [[ $EUID -ne 0 ]]; then
    echo "错误：此脚本必须以root用户运行" >&2
    exit 1
fi

# 定义URL
URL="https://raw.githubusercontent.com/FZDSLR/nixos-loongarch64-sd-image-builder/refs/heads/example-result/example/system_path.txt"

echo "正在下载系统路径文件..."
echo "URL: $URL"

# 下载文件并获取路径
NEW_SYSTEM_PATH=$(curl -s "$URL" | head -n1 | tr -d '\n')

# 检查是否成功获取路径
if [[ -z "$NEW_SYSTEM_PATH" ]]; then
    echo "错误：无法从URL获取系统路径" >&2
    exit 1
fi

echo "获取到的新系统路径: $NEW_SYSTEM_PATH"

# 获取当前系统路径
CURRENT_SYSTEM_PATH=$(readlink -f /nix/var/nix/profiles/system 2>/dev/null || nix-env --profile /nix/var/nix/profiles/system --query --out-path 2>/dev/null | cut -d' ' -f1)

if [[ -n "$CURRENT_SYSTEM_PATH" ]]; then
    echo "当前系统路径: $CURRENT_SYSTEM_PATH"

    # 比较路径是否一致
    if [[ "$CURRENT_SYSTEM_PATH" == "$NEW_SYSTEM_PATH" ]]; then
        echo "系统已经是最新配置，无需更新。"
        exit 0
    else
        echo "检测到系统配置需要更新"
    fi
else
    echo "警告：无法获取当前系统路径，将继续执行更新操作"
fi

# 执行nix-store -r
echo "正在执行 nix-store -r $NEW_SYSTEM_PATH ..."
nix-store -r "$NEW_SYSTEM_PATH"
if [[ $? -ne 0 ]]; then
    echo "错误：nix-store -r 执行失败" >&2
    exit 1
fi

# 执行nix-env --set
echo "正在设置系统配置文件..."
nix-env --profile /nix/var/nix/profiles/system --set "$NEW_SYSTEM_PATH"
if [[ $? -ne 0 ]]; then
    echo "错误：nix-env --set 执行失败" >&2
    exit 1
fi

# 执行switch-to-configuration
echo "正在切换到新配置..."
/nix/var/nix/profiles/system/bin/switch-to-configuration switch
if [[ $? -ne 0 ]]; then
    echo "警告：switch-to-configuration 可能没有完全成功，请检查系统状态" >&2
    exit 1
fi

echo "系统配置切换完成！"

echo "正在清理旧配置..."

echo "正在删除旧系统配置（保留最近5代）..."
nix-env --profile /nix/var/nix/profiles/system --delete-generations +5

echo "删除旧生成..."
nix-collect-garbage

echo "系统更新和清理全部完成！"
