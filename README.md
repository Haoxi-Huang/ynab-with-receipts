# Receipts for YNAB

A personal Ruby on Rails web app that lets you upload receipt photos and link them to your YNAB (You Need A Budget) transactions. When a receipt is linked, a URL to the receipt is written into the YNAB transaction's memo field so you can view the receipt directly from YNAB.

## Features

- **Google OAuth sign-in** restricted to a single authorized email
- **Receipt photo upload** via file picker or mobile camera capture
- **Auto-suggest matching** ranks YNAB transactions by date proximity and amount closeness
- **Manual search** to find any transaction by payee, account, or memo
- **YNAB memo write-back** so you can click through from YNAB to view the receipt
- **Gallery view** with linked/unlinked status badges and filtering

## Prerequisites

- Ruby 3.1+
- Rails 7.0+
- Node.js 18+ (for Tailwind CSS builds)
- SQLite3
- A [Google Cloud OAuth 2.0 client](https://console.cloud.google.com/apis/credentials)
- A [YNAB Personal Access Token](https://app.ynab.com/settings/developer)

## Setup

1. **Clone and install dependencies:**

   ```bash
   git clone <repo-url>
   cd ynab-with-receipts
   bundle install
   ```

2. **Configure secrets** (choose one):

   **Option A: Rails encrypted credentials (recommended)**

   ```bash
   EDITOR="code --wait" bin/rails credentials:edit
   ```

   Add the following YAML:

   ```yaml
   google:
     client_id: your-google-client-id.apps.googleusercontent.com
     client_secret: your-google-client-secret
   authorized_email: you@gmail.com
   ynab:
     access_token: your-ynab-personal-access-token
     budget_id: your-budget-id-uuid
   # app_host: https://your-app.example.com
   ```

   The encrypted file (`config/credentials.yml.enc`) is safe to commit. The decryption key (`config/master.key`) is already gitignored.

   **Option B: Environment variables (simpler for development)**

   ```bash
   cp .env.example .env
   ```

   Edit `.env` and fill in the same values. The app checks encrypted credentials first, then falls back to ENV vars.

   **Required values (either option):**

   - `google.client_id` / `google.client_secret` -- from [Google Cloud Console](https://console.cloud.google.com/apis/credentials). Add `http://localhost:3000/auth/google_oauth2/callback` as an authorized redirect URI.
   - `authorized_email` -- the single Gmail address allowed to sign in.
   - `ynab.access_token` -- your [YNAB personal access token](https://app.ynab.com/settings/developer).
   - `ynab.budget_id` -- your budget UUID. Find it by running:
     ```bash
     curl -H "Authorization: Bearer YOUR_TOKEN" https://api.ynab.com/v1/budgets
     ```

3. **Set up the database:**

   ```bash
   bin/rails db:create db:migrate
   ```

4. **Start the development server:**

   ```bash
   bin/dev
   ```

   Visit [http://localhost:3000](http://localhost:3000).

## Usage

1. Sign in with your authorized Google account
2. Upload receipt photos (use the camera on mobile, or file picker on desktop)
3. Click a receipt, then "Find & Link Transaction" to match it to a YNAB entry
4. The app auto-suggests the best matches based on date and amount
5. Once linked, the receipt URL appears in the YNAB transaction's memo field

## Architecture

- **Rails 7** with Hotwire (Turbo + Stimulus) for dynamic UI
- **Tailwind CSS** for responsive styling
- **Active Storage** with local disk for receipt images
- **YNAB Ruby gem** for API integration
- **OmniAuth** with Google OAuth2 for single-user authentication
- **SQLite** for local data storage

---

We are not affiliated, associated, or in any way officially connected with YNAB or any of its subsidiaries or affiliates. The official YNAB website can be found at [www.ynab.com](https://www.ynab.com).

The names YNAB and You Need A Budget, as well as related names, tradenames, marks, trademarks, emblems, and images are registered trademarks of YNAB.
