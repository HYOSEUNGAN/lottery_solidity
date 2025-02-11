프로젝트 분석 및 요구사항 정리

# Lottery Contract

## 1. 프로젝트 구조

📦 Lottery Contract
├ 📂 lib/forge-std/ # Foundry 표준 라이브러리
└ 📂 src/
└ 📄 Lottery.sol # 메인 컨트랙트

## 2. 개발 환경

Solidity: ^0.8.20
Framework: Foundry
테스트 프레임워크로 forge 사용
스크립트 실행을 위한 cast 도구 제공

## 3. 주요 기능

복권 참여 (enter)
당첨자 선정 (pickWinner)
당첨자 확인 (getWinners)
소유권 이전 (transferOwnership)
비상 출금 (emergencyWithdraw)

## 4. 요구사항 분석

당첨자 수 변경
3명의 당첨자 선정
상금을 3등분하여 분배
참여 제한
주소당 최대 3회 참여 가능
playerEntries 매핑으로 참여 횟수 추적
당첨자 선정 로직
index가 7일 경우: players[7], players[5], players[6] 순서로 당첨
각각 balance/3 만큼 분배
당첨자 조회 기능
백엔드에서 조회 가능한 winners 배열 추가
getWinners() 함수로 조회

## 5. 보안 고려사항

### 5.1 랜덤성 보장

- 현재 구현된 random() 함수의 취약점
  - block.timestamp 조작 가능성
  - miners/validators의 영향력
- 개선 방안:
  - Chainlink VRF 도입 검토
  - 여러 블록 해시 결합
  - 커밋-리빌 패턴 적용

### 5.2 접근 제어

- onlyOwner 패턴 적절히 구현됨
- 추가 고려사항:
  - 일시 정지 기능 (Pausable)
  - 비상 출금 제한 조건
  - 다중 서명 지원

## 6. 가스 최적화

### 6.1 스토리지 최적화

- uint256[] 대신 bytes32 사용 검토
- 불필요한 상태 변수 제거
- 매핑 구조 최적화

### 6.2 로직 최적화

- 루프 최소화
- 불필요한 중복 연산 제거
- 이벤트 인덱싱 최적화

## 7. 개발 개선사항

### 7.1 모듈화

- 컨트랙트 분리 고려
- 컨트랙트 간 조합 가능성
- 테스트 코드 개선 필요
