import dotenvx from "@dotenvx/dotenvx";
import fs from "fs/promises";
import path from "path";
import { Octokit } from "@octokit/rest";
import { fileURLToPath } from 'url';

dotenvx.config();

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const downloadedIssues = path.join(__dirname, 'issues', 'downloaded');

const octokit = new Octokit({
  auth: process.env.GITHUB_TOKEN
});

const REPOSITORY = 'musa-509-spring-2023/philly-mass-appraisals-1';
const [owner, repo] = REPOSITORY.split('/');

const labelMap = {
  'Machine Learning': 'Data Science',
  'Application Eng': 'Front-end',
  'Analytics Eng': 'Analysis',
  'Data Eng': 'Scripting',
};

// Download all issue data from the REPOSITORY
const issuesAndPRs = await octokit.paginate(octokit.issues.listForRepo, {
  owner,
  repo,
  state: 'all',
});

// Filter out the PRs
const issues = issuesAndPRs.filter(i => !i.pull_request);

// Sort the issues by number
const orderedIssues = issues.sort((a, b) => a.number - b.number);

// Save the issues to MD files in the downloadedIssues directory
const issueSlugsPath = path.join(downloadedIssues, 'issue-slugs.yaml');
await fs.writeFile(issueSlugsPath, 'issues:\n');

for (const issue of orderedIssues) {
  const title = issue.title;
  const labels = issue.labels.map(label => labelMap[label.name] || label.name);
  const body = issue.body;

  const slug = `${title.toLowerCase()
    .replace(/ /g, '-')}`
    .replace(/[^a-z0-9-]/g, '');
  const issuePath = path.join(downloadedIssues, `${slug}.md`);
  const issueData = `---
title: ${JSON.stringify(title)}
labels: ${JSON.stringify(labels)}
---

${body}`;
  await fs.writeFile(issuePath, issueData);
  await fs.appendFile(issueSlugsPath, `  - ${slug}\n`);
}
