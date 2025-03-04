/*
  Given a GitHub respsitory account and name, and a project id, this script
  will initialize the repository with issues from the issues/ folder, and
  attach those issues to the project.
*/

import { Octokit } from "@octokit/rest";
import { promises as fs } from "fs/promises";
import * as matter from "gray-matter";
import { parse } from 'yaml';

const octokit = new Octokit();

const variables = {
  gcp_project: 'musa5090s25_team1',
};

// Read the file in issues/to-upload/issue-slugs.yml
const issues = await fs.readFile('issues/to-upload/issue-slugs.yml', 'utf-8');
const issueSlugs = parse(issues).issues;

// For each issue, read the file in issues/to-upload/{issueSlug}.md; parse the
// front matter.
...

// Here is an example of how to create an issue using the octokit API
try {
  await octokit.request('PATCH /repos/{owner}/{repo}/issues/{issue_number}', {
    owner: 'OWNER',
    repo: 'REPO',
    issue_number: 'ISSUE_NUMBER',
    title: 'Found a bug',
    body: 'I\'m having a problem with this.',
    assignees: [
      'octocat'
    ],
    milestone: 1,
    state: 'open',
    labels: [
      'bug'
    ],
    headers: {
      'X-GitHub-Api-Version': '2022-11-28'
    }
  })
} catch (error) {
  if (error instanceof RequestError && error.status === 404) {
    await octokit.request('POST /repos/{owner}/{repo}/issues', {
      owner: 'OWNER',
      repo: 'REPO',
      title: 'Found a bug',
      body: 'I\'m having a problem with this.',
      assignees: [
        'octocat'
      ],
      milestone: 1,
      state: 'open',
      labels: [
        'bug'
      ],
      headers: {
        'X-GitHub-Api-Version': '2022-11-28'
      }
    })
  } else {
    throw error
  }
}
