# Contributing to Python Package Repository
When contributing to this repository, please first discuss the change you wish
to make with the PO for the project or with the
[guardians](#project-guardians) of this repository before making a change.

The following is a set of guidelines for contributing to Python Package Repository
project. These are mostly guidelines, not rules. Use your best judgment, and
feel free to propose changes to this document submitting a patch.

## Code of Conduct
This project and everyone participating in it is governed by the
[ADP Code of Conduct](https://gerrit.ericsson.se/plugins/gitiles/adp-fw/adp-fw-templates/+/master/inner-source-templates/CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Project Guardians
The guardians are the maintainer of this project. They are responsible to
moderate the [discussion forum](https://teams.microsoft.com/l/channel/19%3affba290d2dd2460582800f6e82aa68c7%40thread.tacv2/Python%2520Package%2520Repository?groupId=e5efb26a-ffdd-4815-a293-cc8c6c3627a3&tenantId=92e84ceb-fbfd-47ab-be52-080c6b87953f), guide the contributors and review the
submitted patches.
- Senthil Raja Chermapandian (<senthil.raja.chermapandian@ericsson.com>)

## Development Environment prerequisites
The development framework for Python Package Repository is based on [bob](https://gerrit.ericsson.se/plugins/gitiles/adp-cicd/bob/). To be
able to run bob, the following tools need to exist on the host:
- python3
- bash
- docker
Bob expects you to have a valid docker login towards your docker registry on the
host, currently it can't handle automatic login by itself. If you are using
armdocker, then you can login with the following command:
```text
docker login armdocker.rnd.ericsson.se
```

## How can I use this repository?
This repository contains the source code ofPython Package Repository service including
functional and test code, documentation and configuration files for manual and
automatic build and verification.

If you want to fix a bug or just want to experiment with adding a feature,
you'll want to try the service in your environment using a local copy of the
project's source.

You can start cloning the GIT repository to get your local copy:
```text
git clone ssh://<userid>@gerrit.ericsson.se:29418/MXE/mlops-3pps/pypiserver-build
```
Once you have your local copy, you shall navigate to the root directory and
update the submodules needed to build the project:
```text
git submodule update --init --recursive
```
You can now build the service with the following command, from the root
directory:
```text
./bob/bob build image package
```
You can verify your build running the tests located in the folder `test`
using the following command:
```text
./bob/bob test
```
If you are satisfied with your change and want to submit for review,
create a new git commit and then push it with the following:
```text
git push origin HEAD:refs/for/master
```
**Note:** Please follow the
[guidelines for contributors](#submitting-contributions)
before you push your change for review.

## How Can I Contribute?

### Reporting Bugs
This section guides you through submitting a bug report forPython Package Repository.
Following these guidelines helps maintainers and the community understand your
report, reproduce the behavior, and find related reports.

Before creating bug reports, please check
[this list](#before-submitting-a-bug-report) as you might find out that you
 don't need to create one. When you are creating a bug report,
 please [include as many details as possible](#how-do-i-submit-a-good-bug-report).

**Note:** If you find a **Closed** issue that seems like it is the same
thing that you're experiencing, open a new issue and include a link to
the original issue in the body of your new one.

#### Before Submitting A Bug Report
- **Check the [Service User Guide](link).** You might be able to find
 the cause of the problem and fix things yourself.
- **Check the [FAQs on the forum][forum]** for a list of
 common questions and problems.
- **Perform a search in {% Project JIRA %}**  to see if the problem has already been
reported. If it has **and the issue is still open**, add a comment to the
existing issue instead of opening a new one.
- **Perform a search in the [discussion forum][forum]** for the project to
see if that bug was discussed before.
If not, **consider starting a new thread** to get a quick preliminary
feedback from the project maintainers.

#### How Do I Submit A (Good) Bug Report?
Bugs are tracked at https://eteamproject.internal.ericsson.com/projects/MXESUP/issues.
Select the correct component and create an issue on it providing the following information.

Explain the problem and include additional details to help maintainers reproduce
the problem:
- **Use a clear and descriptive title** for the issue to identify the problem.
- **Describe the exact steps which reproduce the problem** in as many
details as possible.
- **Include details about your configuration and environment**.
- **Describe the behavior you observed** and point out what exactly is
the problem with that behavior.
- **Explain which behavior you expected to see instead and why.**
- **If the problem wasn't triggered by a specific action**, describe what you
were doing before the problem happened.

### Suggesting Features
This section guides you through submitting an enhancement suggestion, including
completely new features and minor improvements to existing functionality.
Following these guidelines helps maintainers and the community understand your
suggestion and find related suggestions.

Before creating feature suggestions, please check
[this list](#before-submitting-a-feature-suggestion) as you might find out
that you don't need to create one. When you are creating a feature suggestion,
please [include as many details as possible](#how-do-i-submit-a-good-feature-suggestion).

#### Before Submitting A Feature Suggestion
- **Check the [Service User Guide](link)** for tips — you might discover
that the feature is already available.
- **Perform a search in {% Project JIRA %}** to see if the feature has already been
suggested. If it has, add a comment to the existing issue instead of
opening a new one.
- **Perform a search in the [discussion forum][forum]** for the project to
see if that enhancement was discussed before.
If not, **consider starting a new thread** to get a quick preliminary
feedback from the project maintainers.

#### How Do I Submit A (Good) Feature Suggestion?
Feature suggestions are tracked as {% Project JIRA %}. Select the correct
component and create an issue on it providing the following information:
- **Use a clear and descriptive title** for the issue to identify
the suggestion.
- **Provide a step-by-step description of the suggested feature** in as many
details as possible.
- **Explain why this feature would be useful** to most users of the service.

### Submitting Contributions
This section guides you through submitting your own contribution, including bug
fixing, new features or any kind of improvement on the content of this
repository. The process described here has several goals:
- Maintain the project's quality
- Fix problems that are important to users
- Engage the community in working toward the best possible solution
- Enable a sustainable system for project's maintainers to review contributions

#### Before Submitting A Contribution
- **Engage the project maintainers** in the proper way so that they are prepared
  to receive your contribution and can provide valuable suggestion on the design
  choices. Follow the guidelines to [report a bug](#reporting-bugs) or to
  [propose an enhancement](#suggesting-features).

#### How Do I Submit A (Good) Contribution?
Please follow these steps to have your contribution considered by the
maintainers:
- **Follow the [styleguides](#styleguides)** when implementing your change.
- **Provide a proper description of the change and the reason for it**,
referring to the associated JIRA issue if it exists.
- **Provide proper automatic tests to verify your change**, extending the
existing test suites or creating new ones in case of new features.
- **Update the project documentation if needed**. In case of new features,
they shall be properly described in the the relevant documentation.
- **Follow [commit message guidelines][commit-msg]** when submitting your
contribution for review.
- After you submit your contribution, **verify that the automatic
[CI pipeline][pipeline] for your change is passing**.
If the CI pipeline is failing, and you believe that the failure is unrelated to
your change, please leave a comment on the change request explaining why you
believe the failure is unrelated. A maintainer will re-run the pipeline for you.
If we conclude that the failure was a false positive, then we will open an issue
to track that problem.
While the prerequisites above must be satisfied prior to having your pull
request reviewed, the reviewer(s) may ask you to complete additional design
work, tests, or other changes before your change request can be ultimately
accepted.

## Styleguides

### {% Code %} Styleguide
- ...

### Documentation Styleguide
- ...

## Git Commit Message Guidelines
- Respect the [commit message Design Rule][commit-dr].
- Include the text *@innersource* in the commit message before pushing an inner
source contribution for review (see [inner source principles][inner-source]).
- Project Guardians will only accept inner source contributions if they include
the text *@innersource* in the commit message.
- ...

### Example commit message
```
Add a new awesome feature
This commit adds an awesome feature to this project following inner source principles.
@innersource
Change-Id: Ia1147f79572a8cf6c6014528f76ec4932f82cbc2
Troublereport: ADPPRG-12345, source: jira
```

**Note:** The text *@innersource* must be present only in commits
that represent inner source contributions. Commits created by a team member
working in the project receiving it must never contain the *@innersource* text.

[adp-code-of-conduct]: https://gerrit.ericsson.se/plugins/gitiles/adp-fw/adp-fw-templates/+/master/inner-source-templates/CODE_OF_CONDUCT.md
[forum]: https://teams.microsoft.com/l/channel/19%3aed0a261d69df4fcda3e700b9b0938d3c%40thread.skype/General?groupId=f7576b61-67d8-4483-afea-3f6e754486ed&tenantId=92e84ceb-fbfd-47ab-be52-080c6b87953f
[bob]: https://gerrit.ericsson.se/plugins/gitiles/adp-cicd/bob/
[pipeline]: https://fem008-eiffel007.rnd.ki.sw.ericsson.se:8443/jenkins/view/ADP-Ref-App/job/adp-ref-catfacts-text-analyzer-precodereview-pipeline/
[commit-dr]: https://confluence.lmera.ericsson.se/display/AA/Artifact+handling+design+rules
[inner-source]: https://adp.ericsson.se/overview/inner-source/inner-source-principles
[commit-msg]: #git-commit-message-guidelines
