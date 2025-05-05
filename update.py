import re
import requests
import hashlib
import sys

# Path to the Homebrew formula file
formula_path = sys.argv[1]

# Extract resources from the formula
def extract_resources(formula_content):
    pattern = r'resource "(.*?)" do.*?url "(.*?)".*?sha256 "(.*?)"'
    matches = re.findall(pattern, formula_content, re.DOTALL)
    return [{"name": name, "url": url, "sha256": sha256} for name, url, sha256 in matches]

# Fetch the latest version and SHA256 from PyPI
def fetch_latest_resource(name):
    pypi_url = f"https://pypi.org/pypi/{name}/json"
    try:
        response = requests.get(pypi_url)
        response.raise_for_status()
        data = response.json()
        latest_version = data["info"]["version"]
        latest_release = data["releases"][latest_version][-1]
        latest_url = latest_release["url"]
        latest_sha256 = hashlib.sha256(requests.get(latest_url).content).hexdigest()
        return {"url": latest_url, "sha256": latest_sha256}
    except Exception as e:
        print(f"Failed to fetch resource for {name}: {e}")
        return None

# Update the formula content with the latest resources
def update_formula_resources(formula_content, resources):
    for resource in resources:
        latest = fetch_latest_resource(resource["name"])
        if latest:
            formula_content = formula_content.replace(resource["url"], latest["url"])
            formula_content = formula_content.replace(resource["sha256"], latest["sha256"])
    return formula_content

# Main script execution
if __name__ == "__main__":
    with open(formula_path, "r") as file:
        formula_content = file.read()

    resources = extract_resources(formula_content)
    updated_formula_content = update_formula_resources(formula_content, resources)

    with open(formula_path, "w") as file:
        file.write(updated_formula_content)

    print("Formula updated successfully!")
