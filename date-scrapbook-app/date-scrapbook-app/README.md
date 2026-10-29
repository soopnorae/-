# 데이트 스크랩북 — 설치 안내

둘만 쓰는 데이트 기록 앱입니다. 기록과 사진은 **Supabase**(무료)에 저장되고, 앱은 웹 주소 하나로 열어서 **폰 홈 화면에 설치**해 씁니다.
전체 소요 시간은 15~20분, 비용은 0원입니다 (무료 플랜: DB 500MB, 사진 1GB — 사진은 자동으로 줄여서 저장하므로 수천 장 들어갑니다).

## 파일 구성

| 파일 | 역할 |
|---|---|
| `index.html` | 앱 본체 (화면·로직 전부) |
| `config.js` | Supabase 주소·키 (비워 두면 앱 첫 화면에서 입력) |
| `manifest.webmanifest`, `sw.js`, `icons/` | 홈 화면 설치·오프라인용 |
| `supabase/schema.sql` | Supabase에 한 번 실행할 설정 SQL |

---

## 1단계 · Supabase 프로젝트 만들기 (5분)

1. https://supabase.com 에서 가입 → **New project**
2. 이름은 아무거나, 비밀번호는 안전한 곳에 적어 두기, Region은 **Northeast Asia (Seoul)** 또는 **Tokyo**
3. 만들어지면 왼쪽 메뉴 **SQL Editor** → **New query** → `supabase/schema.sql` 내용 전체를 붙여넣고 **Run**
   - "Success. No rows returned" 가 뜨면 성공입니다. 테이블 2개, 사진 저장소, 접근 권한, 실시간 반영이 한 번에 만들어집니다.
4. 왼쪽 메뉴 **Project Settings → API** 에서 두 값을 복사
   - **Project URL** (`https://xxxx.supabase.co`)
   - **anon public** 키 (`eyJ...`로 시작하는 긴 문자열)
   - ⚠️ `service_role` 키는 절대 쓰지 마세요. 그건 관리자 키입니다.

## 2단계 · 키 넣기 (1분)

둘 중 편한 쪽을 고르면 됩니다.

- **A. config.js에 넣기 (추천)** — `config.js`를 열어 큰따옴표 안에 URL과 anon 키를 붙여넣고 저장. 이러면 상대방 기기에서도 아무 설정 없이 바로 열립니다.
- **B. 앱 안에서 입력** — `config.js`를 비워 두면 앱을 처음 열 때 입력 화면이 나옵니다. 그 기기에만 저장되며, 상대방에게는 **설정 → 초대 링크 복사**로 보내면 자동으로 연결됩니다.

## 3단계 · 웹에 올리기 (5분)

PWA는 `https://` 주소가 있어야 설치됩니다. 가장 쉬운 두 가지:

**GitHub Pages (무료, 영구)**
1. https://github.com 에서 새 저장소 만들기 (예: `date-scrapbook`, **Private**로 두어도 Pages는 공개됩니다 — 주소를 아는 사람만 열 수 있고, 데이터는 어차피 로그인해야 보입니다)
2. 이 폴더의 파일을 전부 업로드 (**Add file → Upload files**, `icons` 폴더 포함)
3. **Settings → Pages → Build and deployment → Source: Deploy from a branch**, Branch `main` / `/ (root)` → Save
4. 1~2분 뒤 `https://<아이디>.github.io/date-scrapbook/` 주소가 생깁니다

**Netlify Drop (가장 빠름)**
1. https://app.netlify.com/drop 에 이 폴더를 통째로 끌어다 놓기
2. 바로 `https://xxxx.netlify.app` 주소가 생깁니다 (가입하면 주소가 유지됩니다)

## 4단계 · 가입하고 잠그기 (3분)

1. 생긴 주소를 열고 **각자 이메일로 가입** → 메일함의 확인 링크 클릭 → 로그인
   - 확인 메일이 귀찮으면 Supabase **Authentication → Providers → Email → Confirm email** 을 끄면 가입 즉시 로그인됩니다.
2. **둘 다 가입이 끝나면** Supabase **Authentication → Providers → Email** 에서 **Allow new users to sign up** 을 **끕니다.**
   - 이 한 번의 설정으로 주소가 새어 나가도 아무도 새로 가입해 들어올 수 없습니다.
3. 앱 **설정**에서 스크랩북 이름과 처음 만난 날을 넣으면 상단에 D+N 이 표시됩니다.

## 5단계 · 폰에 설치

- **iPhone (Safari)**: 공유 버튼 → **홈 화면에 추가**
- **Android (Chrome)**: 메뉴(⋮) → **홈 화면에 추가** 또는 **앱 설치**

아이콘으로 열면 주소창 없이 앱처럼 뜨고, 한 사람이 올린 기록은 상대 화면에도 몇 초 안에 나타납니다.

---

## 자주 묻는 것

**사진은 어디에 저장되나요?** Supabase Storage의 비공개 `photos` 버킷입니다. 로그인한 두 사람만 볼 수 있고, 올릴 때 긴 변 1600px·JPEG로 자동 축소됩니다.

**데이터를 백업하고 싶어요.** Supabase **Table Editor → entries → Export CSV** 로 기록을, **Storage → photos** 에서 사진을 내려받을 수 있습니다.

**가입을 다시 열고 싶어요 (기기 바꿈 등).** 가입은 계정당 한 번이라 기기를 바꿔도 같은 이메일로 로그인하면 됩니다. 정말 새 계정이 필요하면 4-2의 설정을 잠깐 켰다가 다시 끄세요.

**앱을 고치고 싶어요.** `index.html` 하나에 전부 들어 있습니다. 수정 후 같은 곳에 다시 올리면 다음에 열 때 반영됩니다 (오프라인 캐시 때문에 두 번째 열 때부터 보일 수 있습니다).
