# TalentQuest Protocol

A decentralized skill development and professional certification system that rewards continuous learning on the Stacks blockchain with verifiable NFT credentials.

## Overview

TalentQuest Protocol is designed to incentivize and reward professional skill development through a tokenized talent point system. By mastering skills and maintaining mastery streaks, professionals earn talent points that can be claimed or committed to skill paths for additional benefits. Additionally, users receive NFT professional credentials as verifiable proof of their skill mastery.

## Features

- **Skill Mastery Rewards**: Earn base talent points for mastering professional skills
- **Mastery Streaks**: Build a streak by practicing skills regularly for bonus rewards
- **Point Commitment**: Commit earned points to demonstrate dedication to skill paths
- **Skill Tracking**: Monitor your professional development and mastered skills on-chain
- **NFT Professional Credentials**: Receive unique, transferable NFTs for each skill mastery
- **Verifiable Expertise**: Share and prove your professional achievements with blockchain-backed NFTs

## How It Works

1. **Practice**: Professionals begin skill practice by specifying the expected complexity
2. **Mastery**: Upon mastering a skill, professionals receive base rewards plus streak bonuses and an NFT credential
3. **Streaks**: Maintaining consistent skill practice (daily practice) increases streak multipliers
4. **Claiming**: Earned talent points can be claimed at any time
5. **Commitment**: Optional commitment of points to specific skill paths for longer-term development
6. **NFT Management**: Professional credentials can be viewed and transferred to other users

## Technical Details

### Reward Structure

- Base skill reward: 10 talent points per mastery
- Mastery bonus: 2 additional points per streak tier (up to 7 tiers)
- Maximum potential reward per mastery: 24 points (10 base + 14 mastery bonus)
- Total talent point reserve: 1,000,000 points

### Streak Mechanics

- Daily skill practice builds your mastery streak tier
- Missing a day resets your streak to tier 1
- Each tier increases your rewards by 2 points
- Maximum streak tier is 7 (for a 14 point bonus)

### Commitment System

- Points can be committed to demonstrate dedication to skill paths
- Minimum dedication period: 288 blocks (approximately 2 days)
- Early abandonment penalty: 10% of committed amount
- Successful completion of dedication period returns 100% of committed points

### NFT Credential System

- Each skill mastery generates a unique NFT professional credential
- NFTs contain metadata about the skill complexity, completion date, and mastery level
- Credentials are transferable between users
- Each user can hold up to 100 professional credentials

## Usage

### For Professionals

```clarity
;; Begin skill practice with specified complexity
(contract-call? .talent-quest begin-skill-practice u100)

;; Master a skill after required practice period
(contract-call? .talent-quest master-skill u100)

;; Check your current talent point balance
(contract-call? .talent-quest get-point-balance tx-sender)

;; Claim your earned talent points
(contract-call? .talent-quest claim-talent-points)

;; Commit points to a skill path
(contract-call? .talent-quest commit-to-skill u50)

;; End your commitment after dedication period
(contract-call? .talent-quest end-commitment)

;; View your NFT professional credentials
(contract-call? .talent-quest get-user-credentials tx-sender)
;; View platform statistics
(contract-call? .talent-quest get-platform-stats)

Getting Started

1. Deploy the TalentQuest contract to a Stacks blockchain node
2. Begin your first skill practice by calling `begin-skill-practice`
3. Master the skill after the required practice period
4. Build your streak by practicing skills daily
5. Claim or commit your talent points
6. View and manage your NFT professional credentials


Future Development

- Integration with professional training platforms
- Expansion of skill types and specialized career paths
- Peer endorsement and skill validation mechanisms
- Enhanced NFT metadata with visual representations of credentials
- Cross-platform professional credential verification
- Marketplace for talent recruitment based on verified credentials