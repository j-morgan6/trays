%{
  configs: [
    %{
      name: "default",
      skip_checks: [:config_https, :config_csp], # commonly skipped in dev
      exit_on_high_confidence: true,
      scan_dirs: ["lib", "test"],
      ignore_files: ["priv/static/", "deps/"],
      fail_on: :high
    }
  ]
}
