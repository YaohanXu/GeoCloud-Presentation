/*
  Given a GitHub respsitory account and name, and a project id, this script
  will initialize the repository with issues from the issues/ folder, and
  attach those issues to the project.
*/

import { Octokit } from "@octokit/rest";

const octokit = new Octokit();