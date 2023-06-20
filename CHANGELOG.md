<!-- markdownlint-disable MD024 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v6.1.0](https://github.com/puppetlabs/puppetlabs-wsus_client/tree/v6.1.0) - 2023-06-20

[Full Changelog](https://github.com/puppetlabs/puppetlabs-wsus_client/compare/v6.0.0...v6.1.0)

### Added

- pdksync - (MAINT) - Allow Stdlib 9.x [#209](https://github.com/puppetlabs/puppetlabs-wsus_client/pull/209) ([LukasAud](https://github.com/LukasAud))

### Fixed

- (CONT-967) Replace all uses of validate_*() with assert_type() [#206](https://github.com/puppetlabs/puppetlabs-wsus_client/pull/206) ([david22swan](https://github.com/david22swan))

## [v6.0.0](https://github.com/puppetlabs/puppetlabs-wsus_client/tree/v6.0.0) - 2023-04-20

[Full Changelog](https://github.com/puppetlabs/puppetlabs-wsus_client/compare/v5.0.1...v6.0.0)

### Changed
- (CONT-804) Add Support for Puppet 8 / Drop Support for Puppet 6 [#204](https://github.com/puppetlabs/puppetlabs-wsus_client/pull/204) ([david22swan](https://github.com/david22swan))

## [v5.0.1](https://github.com/puppetlabs/puppetlabs-wsus_client/tree/v5.0.1) - 2023-04-20

[Full Changelog](https://github.com/puppetlabs/puppetlabs-wsus_client/compare/v5.0.0...v5.0.1)

### Fixed

- (CONT-860) Update registry dependency [#202](https://github.com/puppetlabs/puppetlabs-wsus_client/pull/202) ([LukasAud](https://github.com/LukasAud))

## [v5.0.0](https://github.com/puppetlabs/puppetlabs-wsus_client/tree/v5.0.0) - 2023-03-09

[Full Changelog](https://github.com/puppetlabs/puppetlabs-wsus_client/compare/v4.0.0...v5.0.0)

### Added

- pdksync - (FM-8922) - Add Support for Windows 2022 [#175](https://github.com/puppetlabs/puppetlabs-wsus_client/pull/175) ([david22swan](https://github.com/david22swan))

### Changed
- (gh-cat-9) Add specific data types [#181](https://github.com/puppetlabs/puppetlabs-wsus_client/pull/181) ([LukasAud](https://github.com/LukasAud))

### Fixed

- (MAINT) Drop support for Windows 7, 8, 2008 (Server) and 2008 R2 (Server) [#185](https://github.com/puppetlabs/puppetlabs-wsus_client/pull/185) ([jordanbreen28](https://github.com/jordanbreen28))
- adjusted upper limit [#184](https://github.com/puppetlabs/puppetlabs-wsus_client/pull/184) ([prolixalias](https://github.com/prolixalias))

## [v4.0.0](https://github.com/puppetlabs/puppetlabs-wsus_client/tree/v4.0.0) - 2021-03-01

[Full Changelog](https://github.com/puppetlabs/puppetlabs-wsus_client/compare/v3.2.0...v4.0.0)

### Changed
- pdksync - Remove Puppet 5 from testing and bump minimal version to 6.0.0 [#148](https://github.com/puppetlabs/puppetlabs-wsus_client/pull/148) ([carabasdaniel](https://github.com/carabasdaniel))

## [v3.2.0](https://github.com/puppetlabs/puppetlabs-wsus_client/tree/v3.2.0) - 2021-02-18

[Full Changelog](https://github.com/puppetlabs/puppetlabs-wsus_client/compare/v3.1.0...v3.2.0)

### Added

- pdksync - (IAC-973) - Update travis/appveyor to run on new default branch `main` [#134](https://github.com/puppetlabs/puppetlabs-wsus_client/pull/134) ([david22swan](https://github.com/david22swan))

## [v3.1.0](https://github.com/puppetlabs/puppetlabs-wsus_client/tree/v3.1.0) - 2020-01-06

[Full Changelog](https://github.com/puppetlabs/puppetlabs-wsus_client/compare/v3.0.0...v3.1.0)

### Added

- Update metadata.json [#114](https://github.com/puppetlabs/puppetlabs-wsus_client/pull/114) ([sootysec](https://github.com/sootysec))

## [v3.0.0](https://github.com/puppetlabs/puppetlabs-wsus_client/tree/v3.0.0) - 2019-10-18

[Full Changelog](https://github.com/puppetlabs/puppetlabs-wsus_client/compare/v2.0.0...v3.0.0)

### Fixed

- (maint) - Fixes to HISTORY.md and metadata.json [#110](https://github.com/puppetlabs/puppetlabs-wsus_client/pull/110) ([david22swan](https://github.com/david22swan))

## [v2.0.0](https://github.com/puppetlabs/puppetlabs-wsus_client/tree/v2.0.0) - 2019-07-25

[Full Changelog](https://github.com/puppetlabs/puppetlabs-wsus_client/compare/1.1.0...v2.0.0)

### Added

- MODULES-9421 - Stringify module [#101](https://github.com/puppetlabs/puppetlabs-wsus_client/pull/101) ([lionce](https://github.com/lionce))

## [1.1.0](https://github.com/puppetlabs/puppetlabs-wsus_client/tree/1.1.0) - 2018-10-25

[Full Changelog](https://github.com/puppetlabs/puppetlabs-wsus_client/compare/1.0.3...1.1.0)

### Added

- pdksync - (MODULES-7705) - Bumping stdlib dependency from < 5.0.0 to < 6.0.0 [#86](https://github.com/puppetlabs/puppetlabs-wsus_client/pull/86) ([pmcmaw](https://github.com/pmcmaw))
- (MODULES-7222) Create a task to list the Update History [#83](https://github.com/puppetlabs/puppetlabs-wsus_client/pull/83) ([glennsarti](https://github.com/glennsarti))

### Changed
- (MODULES-4837) Update puppet compatibility with 4.7 as lower bound [#71](https://github.com/puppetlabs/puppetlabs-wsus_client/pull/71) ([lbayerlein](https://github.com/lbayerlein))

## [1.0.3](https://github.com/puppetlabs/puppetlabs-wsus_client/tree/1.0.3) - 2016-12-14

[Full Changelog](https://github.com/puppetlabs/puppetlabs-wsus_client/compare/1.0.2...1.0.3)

### Added

- (MODULES-3475) Support AlwaysAutoRebootAtScheduledTimeMinutes [#48](https://github.com/puppetlabs/puppetlabs-wsus_client/pull/48) ([adasko](https://github.com/adasko))
- (MODULES-3016) Support AlwaysAutoRebootAtScheduledTime [#47](https://github.com/puppetlabs/puppetlabs-wsus_client/pull/47) ([jpogran](https://github.com/jpogran))

### Fixed

- (MODULES-3632) Use json_pure always [#61](https://github.com/puppetlabs/puppetlabs-wsus_client/pull/61) ([hunner](https://github.com/hunner))
- (MODULES-2420) omit ensure => running due to "trigger start" [#56](https://github.com/puppetlabs/puppetlabs-wsus_client/pull/56) ([MosesMendoza](https://github.com/MosesMendoza))

## [1.0.2](https://github.com/puppetlabs/puppetlabs-wsus_client/tree/1.0.2) - 2016-05-04

[Full Changelog](https://github.com/puppetlabs/puppetlabs-wsus_client/compare/1.0.1...1.0.2)

## [1.0.1](https://github.com/puppetlabs/puppetlabs-wsus_client/tree/1.0.1) - 2015-12-07

[Full Changelog](https://github.com/puppetlabs/puppetlabs-wsus_client/compare/1.0.0...1.0.1)

## [1.0.0](https://github.com/puppetlabs/puppetlabs-wsus_client/tree/1.0.0) - 2015-08-31

[Full Changelog](https://github.com/puppetlabs/puppetlabs-wsus_client/compare/v0.1.3...1.0.0)

## [v0.1.3](https://github.com/puppetlabs/puppetlabs-wsus_client/tree/v0.1.3) - 2015-07-02

[Full Changelog](https://github.com/puppetlabs/puppetlabs-wsus_client/compare/702fb9da2b7f7ca745262889912ede6c54f8543c...v0.1.3)
