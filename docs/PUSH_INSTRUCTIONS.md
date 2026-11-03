# GitHub-ზე ატვირთვა (5 წუთი)

```bash
git init
git checkout -b main
git add .
git commit -m "chore: initial project structure"
git checkout -b dev
git add . && git commit --allow-empty -m "feat: add task tracker app and unit tests"
git push -u origin main dev        # origin = შენი ცარიელი public repo
```
1. GitHub-ზე შექმენი **Public** რეპოზიტორია → `git remote add origin <URL>`
2. Push-ის შემდეგ გახსენი **Actions** ტაბი, დაელოდე სამივე job-ის გამწვანებას.
3. გადაიღე 3 სქრინშოტი და შეინახე `docs/screenshots/`-ში ზუსტად ამ სახელებით:
   `pipeline.png` (Actions გვერდი), `tests.png` (`python -m pytest -v` ტერმინალში), `app.png` (ბრაუზერი `http://127.0.0.1:5000/health` – ჯერ `bash scripts/deploy.sh`).
4. `git add docs && git commit -m "docs: add screenshots" && git push`
5. სისტემაში ატვირთე რეპოზიტორიის ბმული (დედლაინი 03.11.2026 23:59).
