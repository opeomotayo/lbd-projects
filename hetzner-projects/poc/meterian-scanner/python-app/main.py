import requests

def main():
    response = requests.get("https://example.com")
    print("Response status code:", response.status_code)

if __name__ == "__main__":
    main()

