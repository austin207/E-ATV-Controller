# Contributing to E-ATV RC Controller

## Branch Structure
- `main` - Production-ready code only
- `develop` - Integration branch for testing
- `feature/feature-name` - Individual features
- `hotfix/fix-name` - Urgent production fixes
- `release/v1.x.x` - Release preparation

## Workflow
1. **Create feature branch from develop:**
```
git checkout develop
git pull origin develop
git checkout -b feature/your-feature-name
```

2. **Work on your feature and commit:**
```
git add .
git commit -m "feat: add new controller feature"
```

3. **Push and create PR to develop:**
```
git push -u origin feature/your-feature-name
```

4. **After PR approval and merge to develop, test thoroughly**

5. **When ready for production, create PR from develop to main**

## Commit Message Format
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `style:` - Formatting changes
- `refactor:` - Code refactoring
- `test:` - Adding tests
- `chore:` - Maintenance tasks
