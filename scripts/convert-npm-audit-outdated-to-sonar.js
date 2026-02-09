// convert-npm-audit-outdated-to-sonar.js
import fs from "node:fs";

// Load npm audit and outdated reports
const audit = JSON.parse(fs.readFileSync("npm-audit.json", "utf8"));
const outdated = JSON.parse(fs.readFileSync("npm-outdated.json", "utf8"));

const issues = [];

// Convert npm audit vulnerabilities
for (const vuln of Object.values(audit.vulnerabilities || {})) {
  // Normalize ruleId: prefer CVE/advisory ID if available, else package name
  let ruleId = vuln.name;
  if (Array.isArray(vuln.via) && vuln.via.length > 0) {
    const via = vuln.via[0];
    if (typeof via === "string") {
      ruleId = via;
    } else if (via && typeof via === "object") {
      // advisory id or source if present
      ruleId = via.source || via.url || via.title || vuln.name;
    }
  }

  issues.push({
    engineId: "npm-audit",
    ruleId: String(ruleId), // force to string
    severity: mapSeverity(vuln.severity),
    type: "VULNERABILITY",
    primaryLocation: {
      message: `${vuln.name} ${vuln.range} is vulnerable (${vuln.via
        .map((v) => (typeof v === "string" ? v : v.title || v.source || ""))
        .join(", ")})`,
      filePath: "package-lock.json",
      textRange: { startLine: 1, endLine: 1 },
    },
  });
}

// Convert npm outdated packages
for (const [pkg, info] of Object.entries(outdated)) {
  if (info.current !== info.latest) {
    issues.push({
      engineId: "npm-outdated",
      ruleId: "outdated-dependency",
      severity: mapOutdatedSeverity(info.current, info.latest),
      type: "CODE_SMELL",
      primaryLocation: {
        message: `Package ${pkg} is outdated (current ${info.current}, latest ${info.latest})`,
        filePath: "package.json",
        textRange: { startLine: 1, endLine: 1 },
      },
    });
  }
}

// Severity mapping helpers
function mapSeverity(sev) {
  switch (sev) {
    case "low":
      return "INFO";
    case "moderate":
      return "MINOR";
    case "high":
      return "MAJOR";
    case "critical":
      return "BLOCKER";
    default:
      return "MINOR";
  }
}

function mapOutdatedSeverity(current, latest) {
  // crude version check: major bump = MAJOR, minor/patch = MINOR
  const [cMaj] = current.split(".");
  const [lMaj] = latest.split(".");
  return cMaj !== lMaj ? "MAJOR" : "MINOR";
}

// Write combined report
fs.writeFileSync("npm-sonar.json", JSON.stringify({ issues }, null, 2));
