import dotenvx from "@dotenvx/dotenvx";
dotenvx.config();

import { Octokit } from "@octokit/rest";

const octokit = new Octokit({
  auth: process.env.GITHUB_TOKEN,
});

const org = process.env.GITHUB_ORG;

async function inviteTeamMembers(team_slug, usernames) {
  for (const username of usernames) {
    console.log(`Inviting ${username} to ${team_slug}`);
    await octokit.teams.addOrUpdateMembershipForUserInOrg({
      org, team_slug, username, role: "member",
    });
  }
}

Promise.all([
  inviteTeamMembers('cama-team1', [
    'ruohaoli',
    'samriddhikhar3',
    'nlebovits',
    'alecjayjacobs',
    'alyssafelixa',
    'JJaegal',
    'crusem',
    'shuaiwo',
    'brookeva',
  ]),

  inviteTeamMembers('cama-team2', [
    'davedrenn',
    'mtcliff',
    'junyi2022',
    'richardbarad',
    'miyu-horiuchi',
    'RachelRen-RSH',
    'LuckyLaharlTim',
    'avavani',
    'zhaiyuanhao',
    'jiajiabao01',
  ]),

  inviteTeamMembers('cama-team3', [
    'jingyili219',
    'TrevorKap',
    'xxiaofan-98',
    'YinanLi-15',
    'watsonvv',
    'jiahangl98',
    'Olivegardener',
    'emilyzhou112',
    'YueqiTiffanyLuo',
    'jonathan-manurung',
  ]),
]);
