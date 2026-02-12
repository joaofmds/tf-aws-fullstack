import os


def main():
    upload_path = os.path.join(os.getenv('UPLOAD_DIR'))
    files_in_dir = os.listdir(upload_path)

    for file in files_in_dir:
        if file.endswith(".csv"):
            file = os.path.join(upload_path, file)
            if os.path.isfile(file):
                os.remove(file)


if __name__ == "__main__":
    main()
