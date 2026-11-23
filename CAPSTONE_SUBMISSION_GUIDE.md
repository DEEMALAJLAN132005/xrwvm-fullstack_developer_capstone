# Best Cars Capstone — submission guide

This guide distinguishes committed source code from evidence that must come from a real running lab environment. Do not submit example screenshots or fabricated terminal output.

## Ready: public repository links

- **Task 1 (README.md):**
  https://github.com/DEEMALAJLAN132005/xrwvm-fullstack_developer_capstone/blob/main/README.md
- **Task 3 (About Us):**
  https://github.com/DEEMALAJLAN132005/xrwvm-fullstack_developer_capstone/blob/main/server/frontend/static/About.html
- **Task 4 (Contact Us):**
  https://github.com/DEEMALAJLAN132005/xrwvm-fullstack_developer_capstone/blob/main/server/frontend/static/Contact.html
- **Task 7 (Register.jsx):**
  https://github.com/DEEMALAJLAN132005/xrwvm-fullstack_developer_capstone/blob/main/server/frontend/src/components/Register/Register.jsx

The starter was extended with Django authentication, dealer and review APIs, React pages, sample car models, Express/MongoDB endpoints, and a CI workflow. These commits are not proof that a live deployment has been tested.

## Prepare the Skills Network lab environment

Open the **Full-stack Development Capstone** Cloud IDE (not another course's lab), then paste:

```bash
cd /home/project
if [ -d xrwvm-fullstack_developer_capstone/.git ]; then
  git -C xrwvm-fullstack_developer_capstone pull --ff-only
else
  git clone https://github.com/DEEMALAJLAN132005/xrwvm-fullstack_developer_capstone.git
fi
bash /home/project/xrwvm-fullstack_developer_capstone/scripts/prepare_lab.sh
```

This script **attempts** to install requirements, build React, run migrations, start Docker Compose and Django, and collect real local API output. Lab runtime availability, dependency installation and service readiness must be verified. It does not use your IBM credentials or deploy to Code Engine.

## Terminal-output evidence expected after successful lab execution

- **Task 2:** `django_server` — open the generated log and check the Django server started.
- **Tasks 5 and 6:** `evidence/loginuser` and `evidence/logoutuser` — the script creates a disposable local user and exercises real HTTP endpoints. The password is for the temporary test account only; never commit or reuse it.
- **Tasks 8–11:** `evidence/getdealerreviews`, `getalldealers`, `getdealerbyid`, and `getdealersbyState` (Kansas).
- **Tasks 14–15:** `evidence/getallcarmakes`, after running database migrations.
- **Task 16:** Deploy the sentiment-analysis Flask microservice in Code Engine and capture a real GET request to `<YOUR_SENTIMENT_URL>/analyze/Fantastic%20services`.
- **Task 23:** Run GitHub Actions successfully and paste the actual workflow log or CLI output. Workflow source is at `.github/workflows/main.yml`.
- **Task 24:** Paste the real deployed Django application's URL after deployment.

If any terminal command fails or returns an error, fix the service first. A file containing an error is not valid grading evidence.

## Screenshot evidence still requires the real UI

- **Task 12:** `admin_login.png` — logged-in root Django Admin page.
- **Task 13:** `admin_logout.png` — after signing out of Django Admin.
- **Task 17:** `get_dealers.png` — dealer listing before login.
- **Task 18:** `get_dealers_loggedin.png` — after login, with username and Review Dealer option visible.
- **Task 19:** `dealersbystate.png` — dealers filtered by state, address bar visible.
- **Task 20:** `dealer_id_reviews.png` — selected dealer and reviews, address bar visible.
- **Task 21:** `dealership_review_submission.png` — filled review form **before** submitting.
- **Task 22:** `added_review.png` — posted review rendered on page.
- **Task 25:** `deployed_landingpage.png` — landing page served from the real deployment URL.
- **Task 26:** `deployed_loggedin.png` — deployed page showing the username after login.
- **Task 27:** `deployed_dealer_detail.png` — dealer details in deployment.
- **Task 28:** `deployed_add_review.png` — newly posted review in deployment.

For tasks requiring screenshots, the browser address bar and actual application state must be visible where specified.

## Important

The cloud session and backend deployment addresses are unique to each lab. Update `server/djangoapp/.env` for the real service addresses; localhost defaults only work when the backend services run in the same lab environment. Never submit images or outputs from a different user's project.
