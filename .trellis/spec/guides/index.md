# Shared Thinking Guides

Before modifying any existing value, search for all consumers first. When a change crosses API, service, UI, storage, or task-artifact boundaries, trace the data end to end. When a pattern appears three or more times, search for an existing helper or convention before adding another implementation.

Every important reviewer finding must be checked against the actual code, tests, and trust boundary before being treated as a defect.
