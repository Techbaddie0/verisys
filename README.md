Decentralized KYC Platform Smart Contract
Version 2.1 - Enhanced Security
Overview
This smart contract facilitates a decentralized Know Your Customer (KYC) platform on the Stacks blockchain. The platform allows for secure, verifiable, and transparent identity management, where user registration, verification, and KYC level management are handled in a decentralized manner. Key features include verifier approvals, user data hashing, trust scoring, and detailed error handling, providing a robust and secure platform for identity verification.

Key Features
User Registration & KYC: Allows users to register, providing a hashed representation of their identity data for verification.
Verifier Management: Enables the contract owner to add trusted verifiers, each with trust scores and verification counts.
KYC Levels: Supports multiple KYC levels with specific requirements and verification thresholds.
Trust Scoring: Assigns trust scores to verifiers, allowing flexible management based on performance and integrity.
Access Control & Security: Implements role-based access controls, self-verification prevention, and data expiry checks.
Contract Constants
Status Constants
STATUS-NONE: Default status for users without registration.
STATUS-PENDING: Status after a user registers and is awaiting verification.
STATUS-APPROVED: Status for verified users.
STATUS-REJECTED: Status for users whose verification was denied.
STATUS-EXPIRED: Status for users whose KYC has expired.
Error Codes
Authorization & Data Integrity Errors:
err-unauthorized: Unauthorized action attempted by a non-owner or non-authorized user.
err-already-registered: Error if a verifier or user is already registered.
err-not-registered: Error for actions requiring registration if the entity is unregistered.
err-blacklisted: Indicates a blacklisted user attempting restricted actions.
err-zero-address: Indicates an invalid or zero-address principal.
err-self-verification: Prevents verifiers from verifying themselves.
Validation Errors:
err-invalid-status: Invalid status input.
err-expired: Action attempted on expired data.
err-invalid-data: General invalid data error.
err-invalid-fee: Indicates an invalid platform fee.
err-invalid-trust-score: Error for an invalid trust score.
err-invalid-level: Error for an invalid KYC level.
err-empty-name and err-empty-requirements: Empty string validation errors for KYC levels.
err-invalid-threshold: Error for an invalid verification threshold.
Validation Constants
MAX-TRUST-SCORE & MIN-TRUST-SCORE: Define the range for trust scores.
MAX-VERIFICATION-THRESHOLD: Maximum allowed verification threshold.
MAX-PLATFORM-FEE & MIN-PLATFORM-FEE: Define the range for the platform’s fee.
MAX-KYC-LEVEL: Maximum allowable KYC levels for user identity verification.
Data Structures
Maps
users: Stores registered user details:

Fields: kyc-status, data-hash, timestamp, expiry, verifier, level, metadata.
approved-verifiers: Tracks registered verifiers, including:

Fields: active, verification-count, trust-score, added-at.
blacklisted-users: Lists principals marked as blacklisted.

kyc-levels: Defines the requirements and threshold for each KYC level:

Fields: name, requirements, verification-threshold.
Data Variables
total-users: Counter for total registered users.
total-verifiers: Counter for total approved verifiers.
platform-fee: Platform fee for KYC registration (adjustable by the contract owner).
Core Functions
Validation Helper Functions
is-valid-status: Confirms if a given status is valid.
is-valid-trust-score: Checks if a trust score is within the acceptable range.
is-valid-fee: Ensures a fee falls within platform-defined limits.
is-valid-kyc-level: Verifies if a given KYC level is allowed.
is-valid-threshold: Validates that the verification threshold is within bounds.
is-valid-principal: Checks for valid principals, excluding contract owner and self.
Private Functions
is-approved-verifier: Checks if a verifier is active and prevents self-verification.
is-expired: Checks if a user’s KYC data has expired.
increment-verifier-count: Increments the verification count for an approved verifier.
Public Functions
Admin Functions
set-platform-fee:

Allows the contract owner to update the platform fee.
Includes validation to ensure the new fee is within defined bounds.
add-approved-verifier:

Adds a new verifier if they are not already registered.
Updates the total verifier count and sets initial trust score and verification count.
update-verifier-trust-score:

Allows the contract owner to update a verifier’s trust score within valid limits.
KYC Level Management
add-kyc-level:

Adds a new KYC level with a specified name, requirements, and threshold.
Validates the level, strings, and verification threshold before saving.
kyc-level-exists:

Read-only function to check if a KYC level already exists.
Usage Flow
Adding Verifiers:

The contract owner can register verifiers with add-approved-verifier, setting them as trusted entities on the platform.
Verifiers have a trust score and an initial count of verifications, which can be updated.
KYC Registration:

Users register on the platform by providing a data-hash and necessary information, awaiting verification by an approved verifier.
KYC Level Configuration:

The contract owner can configure KYC levels with specific requirements and verification thresholds via add-kyc-level.
Verification Process:
Verifiers can verify users, update trust scores, and mark KYC as approved, rejected, or expired, based on verification data.
Platform Fee Management:

The contract owner can set the platform-fee to cover operational costs, ensuring it falls within defined limits.
Security and Access Control
Role-Based Access: Only the contract owner can modify verifiers, KYC levels, and platform fee settings.
Self-Verification Prevention: Verifiers are prevented from verifying themselves to maintain integrity.
Data Expiry Checks: Expired user data is managed by automatically changing the KYC status, preventing unauthorized use of outdated verifications.
Blacklist Handling: Blacklisted users are restricted from performing sensitive actions on the platform.

