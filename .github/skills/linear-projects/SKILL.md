---
name: linear-projects
description: 'Manage and query Linear projects. Use when you need to list, search, create, update, or track project progress in Linear. Triggers: list projects, search projects, create project, update project, view project status, link issues to project.'
---

# Linear Projects Skill

## When to Use This Skill
- When you need to list or search Linear projects
- When creating or updating projects
- When viewing project status, members, or progress
- When linking issues to projects
- When reporting on project health or velocity

## Example Triggers
- "Show all active projects"
- "Create a new project for release X"
- "Add user to project Y"
- "Which issues belong to project Z?"

## Prerequisites
- Linear API access and authentication
- Project/team context if filtering by team

## Step-by-Step Workflows
1. List all projects (optionally by team or status)
2. Search projects by name, status, or member
3. View project details (description, status, members, issues)
4. Create new projects (name, description, members)
5. Update project fields (status, members, description)
6. Track project progress and health
7. Link/unlink issues to projects

## Troubleshooting
- Ensure API token is valid and has correct permissions
- Check that project names match Linear configuration
- Keep project members and status up to date

## References
- [Linear API Docs](https://developers.linear.app/docs/graphql/queries/projects)
name: linear-projects
description: 'Manage and query Linear projects. Use for listing, searching, creating, updating, and tracking project progress. Covers project details, status, members, and associated issues.'
