import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :code_horizon, CodeHorizon.Repo,
  username: "postgres",
  password: "postgres",
  database: "code_horizon_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :code_horizon, CodeHorizonWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "cPNzM6yNbuYM9FcYYtqL/PPFpiGQD5Tdxe4pRe8KYGFJ8gwI3Zgl6VL80H6pFeOp",
  server: true

config :code_horizon,
  impersonation_enabled?: true,
  gdpr_mode: false

# In test we don't send emails.
config :code_horizon, CodeHorizon.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :email_checker, validations: [EmailChecker.Check.Format]
config :code_horizon, :env, :test

# Wallaby related settings:
config :wallaby, otp_app: :code_horizon, screenshot_on_failure: true, js_logger: nil
config :code_horizon, :sandbox, Ecto.Adapters.SQL.Sandbox

# Oban - Disable plugins, enqueueing scheduled jobs and job dispatching altogether when testing
config :code_horizon, Oban, testing: :manual

config :exvcr,
  global_mock: true,
  vcr_cassette_library_dir: "test/support/fixtures/vcr_cassettes",
  filter_request_headers: ["Authorization"]

# Disable automatic timezone data updates during testing
config :tzdata, :autoupdate, :disabled

config :code_horizon, :billing_entity, :org

config :code_horizon, :billing_provider, CodeHorizon.Billing.Providers.Stripe

config :code_horizon, :billing_products, [
  %{
    id: "prod1",
    name: "Prod 1",
    description: "Prod 1 description",
    features: [
      "Prod 1 feature 1",
      "Prod 1 feature 2",
      "Prod 1 feature 3"
    ],
    plans: [
      %{
        id: "plan1-1",
        name: "Plan 1",
        amount: 100,
        interval: :month,
        allow_promotion_codes: true,
        items: [
          %{price: "item1-1-1", quantity: 1}
        ]
      }
    ]
  },
  %{
    id: "prod2",
    name: "Prod 2",
    description: "Prod 2 description",
    features: [
      "Prod 1 feature 1",
      "Prod 1 feature 2"
    ],
    plans: [
      %{
        id: "plan2-1",
        name: "Plan 2-1",
        amount: 200,
        interval: :month,
        allow_promotion_codes: true,
        items: [
          %{price: "item2-1-1", quantity: 1},
          %{price: "item2-1-2", quantity: 1}
        ]
      },
      %{
        id: "plan2-2",
        name: "Plan 2-2",
        amount: 2_000,
        interval: :year,
        allow_promotion_codes: true,
        items: [
          %{price: "item2-1-1", quantity: 1},
          %{price: "item2-2-1", quantity: 1}
        ]
      }
    ]
  },
  %{
    # this is a "real" product in Petal Pro's Stripe test account,
    # used for testing against the Stripe API, in conjunction with ExVCR
    id: "stripe-test-plan-a",
    name: "Petal Pro Test Plan A",
    description: "Petal Pro Test Plan A",
    features: [],
    plans: [
      %{
        id: "stripe-test-plan-a-monthly",
        name: "Monthly",
        amount: 199,
        interval: :month,
        allow_promotion_codes: true,
        trial_days: 7,
        items: [
          %{price: "price_1OQj8TIWVkWpNCp7ZlUSOaI9", quantity: 1}
        ]
      },
      %{
        id: "stripe-test-plan-a-yearly",
        name: "Yearly",
        amount: 1900,
        interval: :month,
        allow_promotion_codes: true,
        items: [
          %{price: "price_1OQj8pIWVkWpNCp74VstFtnd", quantity: 1}
        ]
      }
    ]
  }
]
