# Git helpers
status:
	git status

add:
	git add .

commit:
	git commit -m "$(m)"

# usage: make commit m="Your commit message" 

push:
	git push origin main

post:
	git add . && git commit -m "$(m)" && git push origin main

stats:
	git log --author="$(author)" --oneline --shortstat --after="$(after)" | \
	grep 'insertions' | awk '{ add+=$$4; remove+=$$6 } END { print "Added:", add, "Removed:", remove }'

# usage: make stats author="ahsanjahangirmir" after="2025-09-11" 

# get count of commits made 
commits:
	git log --pretty=format:"%ad - %an: %s" --author="$(author)" --after="$(after)" | wc -l

# make commits author="ahsanjahangirmir" after="2025-09-11"

# show last 5 commits in one line
last:
	git log -5 --oneline --decorate --color

# show branches
branches:
	git branch -a

# show current branch 
current_branch:
	git rev-parse --abbrev-ref HEAD

# show changes in last commit
changes:
	git show --stat

# undo last commit
undo:
	git reset --soft HEAD~1

# clean untracked files
clean:
	git clean -fd

owner_update:
	git config --local user.name "ahsanjahangirmir" && git config --local user.email "ahsanjahangirmir@gmail.com"

owner:
	git config user.email  && git config user.name