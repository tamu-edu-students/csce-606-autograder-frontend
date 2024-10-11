# Team Working Agreement

## Purpose
This working agreement outlines the team’s shared guidelines, expectations, and values to promote effective collaboration and self-management.

---

## Scrum Values
Our working agreement is built upon the following Scrum values:
- Courage: Speak up about challenges, propose solutions, and take on difficult tasks.
- Commitment: Be fully dedicated to delivering the sprint goals and supporting the team.
- Focus: Prioritize work that delivers value and minimizes distractions.
- Openness: Be transparent about progress, challenges, and ideas.
- Respect: Value each team member’s contribution and maintain a positive work environment.

---

## Meetings
- Scrum Events: All team members will attend Scrum events on time.
  - Daily Standup: 10:00am, 15-minute duration.
  - Weekly Client Meeting: Every Friday from 11:00am-12:00pm
  - Sprint Planning: Held at the start of each sprint.
  - Sprint Retrospective and Review: Held at the end of each sprint.
  
---

## Communication
- Channels: 
  - Primary communication through Slack.
  - Urgent matters via text messages.
- Response Time:
  - Acknowledge messages within 2 hours during working hours (9 AM – 5 PM).
    - Even a simple thumbs-up is sufficient
  - Response within 24 hours outside working hours unless marked urgent.

---

## Development Best Practices

- Never commit to the `main` branch directly.

   1. Instead, create a separate branch for your new code, and use pull request (PR) to apply your
      new code to the `main` branch.

- Keep your commits atomic
   1. Each commit should contain a single unit of work that involves only a single task
   2. Limiting the scope of a commit enables changes to be more easily applied and reverted
   3. Commit messages should be descriptive

- Write concise titles and detailed descriptions for PRs.

   1. The PR description should be well organized and provide the following information.
      1. Explanations of the context
      2. Detailed description of the changes
      3. Testing approach and result

- Create small PRs.

   1. Each PR should complete one and only one task. Keep your tasks as small as possible.
   2. Try to limit the line of change in each PR to **200** (suggested value). Smaller PRs
      accelerate code reviews significantly.
   3. For example, you implemented a feature in a new branch. Before creating PR, you found a typo
      in a component unrelated to your changes. In this case, create a separate PR for that typo fix.

- Request reviews for your PR.

   1. Each PR should be reviewed by at least one team member (the Product Owner).
   2. If your PR involves changes to a component/module, the team member mainly responsible
      for it should be on the reviewer list as well.
   3. If your PR involves important changes to the code base, add more team members to make them
      aware of the changes.

- Each PR should be merged by the author.
   1. For small changes, approval from one reviewer is sufficient.
   2. For important changes, all the reviewers need to inspect the content. In this case, the author
      should obtain approvals from all reviewers, and then merge the changes into the `main` branch.

[Additional information on version control best practices](https://about.gitlab.com/topics/version-control/version-control-best-practices/#write-descriptive-commit-messages)

---

## Tools & Documentation
- Tools: 
  - Version control with Git and GitHub.
  - Task management with GitHub Projects.
  - Coding standards followed via rubocop and rubycritic
  - Code Climate used to ensure quality
  
- **Definition of Done**: 
  - Code is unit tested
  - Acceptance testing passes
  - No previously passing tests are failing
  - Reviewed through GitHub pull requests
  - Passes all automated tests
  - Code has no `rubocop` violations
  
---

## Work Process
- **Approach**: 
  - We will use pair-programming for complex tasks and debugging sessions.
  - Each team member is responsible for updating the sprint backlog and marking tasks as complete.
  
---

## Conflict Resolution
- Issues or conflicts will first be respectfully addressed in private between the individuals involved.
- If unresolved, bring the issue to the Scrum Master for mediation.

---

## Continuous Improvement
- The working agreement will be reviewed at the end of every sprint during the retrospective to ensure it continues to serve the team effectively.

---

_Last Updated: [10/10/2024]_
