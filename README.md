# ffshake
**ffshake** is a Bash script that generates a **camera shake / wiggle effect** on an image or video using FFmpeg.  
It applies horizontal/vertical wiggle, optional rotation, and chromatic aberration effects for animated shake videos.  
This project was born out of the absence of this effect in open-source video editors such as Shotcut and Kdenlive, which do not currently plan to implement it.

## 🚀 Features

- Works with both **image** and **video** input.
- Configurable **wiggle amplitude**, **speed**, and **rotation**.
- Optional **chromatic aberration** effect.
- Supports **additional FFmpeg args** for custom encoding settings.
- No dependencies besides **FFmpeg** and Bash.

## 🎬 Demo
https://github.com/user-attachments/assets/a9d33135-536f-453a-b538-05ff152ce4f4

[Settings used: `-i shake.png -o shake.mp4 --duration 15 --amp-x 40 --amp-y 40 --rot-deg 8 --args -c:v h264_nvenc`]

## 📦 Requirements

- FFmpeg (with filter support) installed and in your PATH
- Bash shell (Linux/macOS/WSL)

## 🛠 Installation

Simply clone the repository:

```bash
git clone https://github.com/ycomiti/ffshake.git
cd ffshake
chmod +x ffshake.sh
````

## 📋 Usage

```
./ffshake.sh -i input_file [options]
```

### 🎯 Basic Example

Apply shake to an image (10s default duration):

```bash
./ffshake.sh -i input.png -o output.mp4
```

### 🔧 With Custom Parameters

```bash
./ffshake.sh \
  -i input.png \
  -o shake.mp4 \
  --duration 15 \
  --amp-x 40 \
  --amp-y 40 \
  --rot-deg 8 \
  --args -c:v h264_nvenc -b:v 6M -r 60
```

## 📌 Options

| Option                     | Description                                                |
| -------------------------- | ---------------------------------------------------------- |
| `-i FILE`                  | Input file (image or video)                                |
| `-o FILE`                  | Output file (default: `output.mp4`)                        |
| `-r WxH`                   | Output resolution (default: `1920x1080`)                   |
| `--rotate` / `--no-rotate` | Enable or disable rotation                                 |
| `--duration N`             | Duration in seconds for image inputs                       |
| `--amp-x N`                | Horizontal shake amplitude                                 |
| `--amp-y N`                | Vertical shake amplitude                                   |
| `--rot-deg N`              | Rotation amplitude (degrees)                               |
| `--speed-x N`              | Horizontal shake speed (period)                            |
| `--speed-y N`              | Vertical shake speed (period)                              |
| `--speed-rot N`            | Rotation speed (period)                                    |
| `--chroma-cb N`            | Chromatic aberration Cb shift                              |
| `--chroma-cr N`            | Chromatic aberration Cr shift                              |
| `--overscan WxH`           | Overscan resolution                                        |
| `--args ARG...`            | Additional FFmpeg arguments passed directly to the command |

## 📁 Example Commands

### Increase frame rate

```bash
./ffshake.sh -i input.png --args -r 60
```

### Use NVENC hardware encoder

```bash
./ffshake.sh -i input.mp4 --args -c:v h264_nvenc -preset p4
```

## 🧩 How It Works

The script builds a **filter graph** combining:

* `rotate` — for rotation wiggle
* `scale` / `crop` — for overscan and movement
* `chromashift` — for chromatic aberration
* `sin()`‑based expressions to animate shake

These filters are chained using FFmpeg’s expression evaluation.

## 🤝 Contributing

Contributions are welcome! Please open an issue or pull request.

1. Fork the repo
2. Create a feature branch
3. Submit a PR

## 📜 License

This project is licensed under the **GNU General Public License v3.0**.

See `LICENSE` for details.
