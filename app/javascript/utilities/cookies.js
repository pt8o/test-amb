function getCsrfTokenFromCookie(cookies) {
  const splitCookies = cookies.split("; ");
  return splitCookies
    .find((cookie) => cookie.startsWith("CSRF-TOKEN="))
    .split("=")[1];
}

const CSRF_TOKEN = getCsrfTokenFromCookie(document.cookie);

export { CSRF_TOKEN };
