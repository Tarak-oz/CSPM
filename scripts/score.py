#!/usr/bin/env python3
import json
import sys
from pathlib import Path

BASE = {"low": 25, "medium": 45, "high": 65, "critical": 80}

def score(finding):
    value = BASE[finding["severity"].lower()]
    if finding.get("internet_exposed"):
        value += 10
    if finding.get("sensitive_data"):
        value += 10
    if finding.get("privileged_path"):
        value += 20
    return min(value, 100)

def band(value):
    if value >= 90:
        return "CRITICAL"
    if value >= 70:
        return "HIGH"
    if value >= 50:
        return "MEDIUM"
    return "LOW"

def main():
    path = Path(sys.argv[1] if len(sys.argv) > 1 else "examples/sample-findings.json")
    findings = json.loads(path.read_text())
    ranked = sorted(((score(f), f) for f in findings), key=lambda item: item[0], reverse=True)
    for value, finding in ranked:
        print(f"{band(value):8}  {finding['id']:24} score={value:<3}  {finding['title']}")

if __name__ == "__main__":
    main()
