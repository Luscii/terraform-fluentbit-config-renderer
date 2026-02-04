---
name: linear-issues
description: 'Manage, search, and interact with Linear issues. Use when you need to list, filter, create, update, assign, or close issues in Linear. Triggers: list issues, search issues, create issue, update issue, assign issue, close issue, link issue to project or cycle.'
---

# Linear Issues Skill

## When to Use This Skill
- When you need to list, search, or filter Linear issues
- When creating, updating, or closing issues
- When assigning issues to users or teams
- When adding or removing labels or linking to projects
- When performing bulk status changes or triage

## Example Triggers
- "Show all open issues in Platform team"
- "Create a new issue in project X"
- "Set all issues with label bug to Done"
- "Search issues with text 'deployment failed'"

## Prerequisites
- Linear API access and authentication
- Project/team context if filtering by team or project

## Step-by-Step Workflows
1. List issues by team, project, status, label, or assignee
2. Search issues with filters (status, priority, text, etc.)
3. View issue details (description, status, labels, comments)
4. Create new issues (title, description, labels, assignee, project)
5. Update issue fields (status, labels, assignee, project, cycle)
6. Close, reopen, or delete issues
7. Bulk update status or assignee
8. Link issues to projects, cycles, or other issues

## Troubleshooting
- Ensure API token is valid and has correct permissions
- Check that team/project names match Linear configuration
- Use clear, descriptive titles and descriptions for issues

## References
- [Linear API Docs](https://developers.linear.app/docs/graphql/queries/issues)
name: linear-issues
description: 'Manage, search, and interact with Linear issues. Use for listing, filtering, creating, updating, assigning, and closing issues. Covers status, labels, assignees, and linking to projects or cycles.'
