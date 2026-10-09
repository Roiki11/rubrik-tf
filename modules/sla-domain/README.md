# Rubrik SLA Domain

Creates and manages a Rubrik SLA Domain using the `sullivtr/graphql` provider.
The caller must configure the provider. The module supports the SLA name,
description, object types, all snapshot schedule cadences accepted by Rubrik's
`GlobalSnapshotScheduleInput`, and optional archive targets using
`ArchivalSpecInput`.

```hcl
module "postgresql_sla" {
  source = "./modules/sla-domain"

  name        = "PostgreSQL daily"
  description = "Daily protection for PostgreSQL clusters"
  object_types = [
    "POSTGRES_DB_CLUSTER_OBJECT_TYPE",
  ]
  snapshot_schedule = {
    daily = {
      basicSchedule = {
        frequency     = 1
        retention     = 30
        retentionUnit = "DAYS"
      }
    }
  }
  archival_specs = [
    {
      archivalGroupId = "00000000-0000-0000-0000-000000000000"
      threshold       = 30
      thresholdUnit   = "DAYS"
    }
  ]
}
```

## Snapshot schedule fields

`snapshot_schedule` is passed through to Rubrik as a
`GlobalSnapshotScheduleInput`. It accepts any combination of these optional
cadences:

| Field | Schedule input | Cadence-specific fields |
|---|---|---|
| `minute` | `MinuteSnapshotScheduleInput` | `basicSchedule` |
| `hourly` | `HourlySnapshotScheduleInput` | `basicSchedule` |
| `daily` | `DailySnapshotScheduleInput` | `basicSchedule`, optional `restrictToDaysOfWeek` |
| `weekly` | `WeeklySnapshotScheduleInput` | `basicSchedule`, optional `dayOfWeek` and/or `daysOfWeek` |
| `monthly` | `MonthlySnapshotScheduleInput` | `basicSchedule`, optional `dayOfMonth` and/or `daysOfMonth` |
| `quarterly` | `QuarterlySnapshotScheduleInput` | `basicSchedule`, optional `dayOfQuarter` and `quarterStartMonth` |
| `yearly` | `YearlySnapshotScheduleInput` | `basicSchedule`, optional `dayOfYear`, `yearStartMonth`, and `daysOfYear` |

Each `basicSchedule` accepts `frequency` (integer), `retention` (integer),
and `retentionUnit` (`MINUTES`, `HOURS`, `DAYS`, `WEEKS`, `MONTHS`,
`QUARTERS`, or `YEARS`). Daily day restrictions use `DayOfWeek` values
`MONDAY` through `SUNDAY`. Weekly `daysOfWeek` entries contain
`dayOfWeek`; monthly `daysOfMonth` entries can contain `specificDate` with a
`dateOffset`, or `dayOfWeekPattern` with `weekOrdinal` and `dayOfWeek`.
`weekOrdinal` supports `FIRST`, `SECOND`, `THIRD`, `FOURTH`, and `LAST`.
Monthly `dayOfMonth` supports `FIRST_DAY`, `FIFTEENTH`, and `LAST_DAY`.
Quarterly `dayOfQuarter` and yearly `dayOfYear` support `FIRST_DAY` and
`LAST_DAY`; `quarterStartMonth`, `yearStartMonth`, and `monthInYear` use
month values `JANUARY` through `DECEMBER`. Yearly `daysOfYear` entries contain
`monthInYear` and a `dayOfMonthSpecification` using the same monthly day
specification. The API schema for the target Rubrik version remains
authoritative for valid combinations and any version-specific differences.

This example shows the available schedule shapes; choose only the cadences
and selector fields supported for your SLA and Rubrik version:

```hcl
snapshot_schedule = {
  minute = {
    basicSchedule = {
      frequency     = 15
      retention     = 1
      retentionUnit = "DAYS"
    }
  }
  hourly = {
    basicSchedule = {
      frequency     = 1
      retention     = 7
      retentionUnit = "DAYS"
    }
  }
  daily = {
    basicSchedule = {
      frequency     = 1
      retention     = 30
      retentionUnit = "DAYS"
    }
    restrictToDaysOfWeek = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY"]
  }
  weekly = {
    basicSchedule = {
      frequency     = 1
      retention     = 12
      retentionUnit = "WEEKS"
    }
    daysOfWeek = [
      { dayOfWeek = "MONDAY" },
      { dayOfWeek = "FRIDAY" },
    ]
  }
  monthly = {
    basicSchedule = {
      frequency     = 1
      retention     = 12
      retentionUnit = "MONTHS"
    }
    daysOfMonth = [
      { specificDate = { dateOffset = 1 } },
      { dayOfWeekPattern = { weekOrdinal = "LAST", dayOfWeek = "FRIDAY" } },
    ]
  }
  quarterly = {
    basicSchedule = {
      frequency     = 1
      retention     = 4
      retentionUnit = "YEARS"
    }
    dayOfQuarter     = "FIRST_DAY"
    quarterStartMonth = "JANUARY"
  }
  yearly = {
    basicSchedule = {
      frequency     = 1
      retention     = 5
      retentionUnit = "YEARS"
    }
    dayOfYear     = "FIRST_DAY"
    yearStartMonth = "JANUARY"
    daysOfYear = [
      {
        monthInYear = "JANUARY"
        dayOfMonthSpecification = {
          specificDate = { dateOffset = 1 }
        }
      }
    ]
  }
}
```

## Archive configuration

`archival_specs` is an optional list of Rubrik `ArchivalSpecInput` objects
passed on both create and update. Each entry can include the fields supported
by the API, including:

- `archivalGroupId`: ID of the configured Rubrik archival group.
- `threshold` and `thresholdUnit`: when snapshots become eligible for archive.
- `frequencies`: archival frequencies.
- `archivalTieringSpecInput`: tiering options, such as instant tiering,
  minimum accessible duration, cold storage class, and whether to tier
  existing snapshots.
- `archivalLocationToClusterMapping`: cluster UUID to archival location ID
  mappings when required by the deployment.
- `isComplianceImmutabilityEnabled`: compliance immutability setting.
- `databaseLogRetentionInfo`: workload-specific database log retention.

`archivalTieringSpecInput` accepts `isInstantTieringEnabled`,
`minAccessibleDurationInSeconds`, `coldStorageClass`, and
`shouldTierExistingSnapshots`. Each archival location mapping accepts
`clusterUuid` and `locationId`.

The exact fields, enum values, and combinations are version- and
configuration-dependent; check the Rubrik GraphQL schema and use an archival
group/location already configured in Rubrik. For example, a simple archive
threshold can be declared as:

```hcl
archival_specs = [
  {
    archivalGroupId = "00000000-0000-0000-0000-000000000000"
    threshold       = 30
    thresholdUnit   = "DAYS"
  }
]
```

The module uses `gql_files/create-global-sla-managed.graphql`,
`gql_files/update-global-sla-managed.graphql`,
`gql_files/mutation-delete-global-sla.graphql`, and
`gql_files/query-sla-domain.graphql`. Destroy deletes the SLA Domain. Rubrik
may reject deletion while the domain is assigned to protected workloads or
otherwise in use.

The provider's generic GraphQL mutation resource does not reconcile mutation
inputs against a read response, so remote state verification is disabled.
Terraform still reads the SLA Domain and uses its ID for updates and deletes.
