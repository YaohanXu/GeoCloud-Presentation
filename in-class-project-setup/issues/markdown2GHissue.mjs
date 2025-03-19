import { Octokit } from "@octokit/rest";
import fs from "fs/promises";
import matter from "gray-matter";
import { parse } from 'yaml';
import 'dotenv/config';

// Access the environment variable
const githubToken = process.env.GITHUB_TOKEN;

const octokit = new Octokit({
  auth: githubToken,
});

// Define default label colors (optional)
const defaultLabelColors = {
  "Front-end": "1D76DB", // Blue
  "Scripting": "D93F0B",       // Red
  "Analysis": "0E8A16", // Green
  "Data Science": "5319E7", // Purple
  "Get Started": "FBCA04", // Yellow
};

const variables = {
  gcp_project: 'musa5090s25_team1',
};

async function ensureLabelExists(labelName, labelColor) {
  try {
    // Check if the label already exists
    await octokit.request("GET /repos/{owner}/{repo}/labels/{name}", {
      owner: 'Weitzman-MUSA-GeoCloud', // Replace with your GitHub username or organization
      repo: 's25-team1-cama', // Replace with your repository name
      name: labelName,
    });

    // If the label exists, update its color
    await octokit.request("PATCH /repos/{owner}/{repo}/labels/{name}", {
      owner: 'Weitzman-MUSA-GeoCloud', // Replace with your GitHub username or organization
      repo: 's25-team1-cama', // Replace with your repository name
      name: labelName,
      color: labelColor || "FFFFFF", // Update the color
      headers: {
        "X-GitHub-Api-Version": "2022-11-28",
      },
    });
    console.log(`Updated label "${labelName}" with color #${labelColor || "FFFFFF"}.`);
  } catch (error) {
    if (error.status === 404) {
      // If the label doesn't exist, create it
      await octokit.request("POST /repos/{owner}/{repo}/labels", {
        owner: 'Weitzman-MUSA-GeoCloud', // Replace with your GitHub username or organization
        repo: 's25-team1-cama', // Replace with your repository name
        name: labelName,
        color: labelColor || "FFFFFF", // Default to white if no color is provided
        headers: {
          "X-GitHub-Api-Version": "2022-11-28",
        },
      });
      console.log(`Created label "${labelName}" with color #${labelColor || "FFFFFF"}.`);
    } else {
      throw error;
    }
  }
}

async function main() {
  // Read the file in issues/to-upload/issue-slugs.yml
  const issues = await fs.readFile('to-upload/issue-slugs.yaml', 'utf-8');
  const issueSlugs = parse(issues).issues;

  // For each issue, read the file in issues/to-upload/{issueSlug}.md; parse the front matter.
  for (const [issueIndex, issueSlug] of issueSlugs.entries()) {
    const filePath = `to-upload/${issueSlug}.md`;
    const fileContent = await fs.readFile(filePath, 'utf-8');
    const { data: frontMatter, content: body } = matter(fileContent);

    // Extract relevant fields from the front matter
    const { title, labels } = frontMatter;

    // Ensure all labels exist (create them if they don't)
    if (labels && Array.isArray(labels)) {
      for (const labelName of labels) {
        // Use a default color if defined, otherwise use a fallback color
        const labelColor = defaultLabelColors[labelName] || "FFFFFF"; // Fallback to white
        await ensureLabelExists(labelName, labelColor);
      }
    }

    try {
      // Try to update the issue if it already exists
      await octokit.request('PATCH /repos/{owner}/{repo}/issues/{issue_number}', {
        owner: 'Weitzman-MUSA-GeoCloud', // Replace with your GitHub username or organization
        repo: 's25-team1-cama', // Replace with your repository name
        issue_number: issueIndex + 1, // Assuming the issue slug is the issue number
        title,
        body,
        labels,
        headers: {
          'X-GitHub-Api-Version': '2022-11-28'
        }
      });
      console.log(`Updated issue: ${title}`);
    } catch (error) {
      if (error.status === 404) {
        // If the issue doesn't exist, create a new one
        await octokit.request('POST /repos/{owner}/{repo}/issues', {
          owner: 'Weitzman-MUSA-GeoCloud', // Replace with your GitHub username or organization
          repo: 's25-team1-cama', // Replace with your repository name
          title,
          body,
          labels,
          headers: {
            'X-GitHub-Api-Version': '2022-11-28'
          }
        });
        console.log(`Created issue: ${title}`);
      } else {
        throw error;
      }
    }
  }
}

main().catch(console.error);