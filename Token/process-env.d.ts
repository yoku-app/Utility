export {};

declare global {
    namespace NodeJS {
        interface ProcessEnv {
            [key: string]: string | undefined;
            SUPABASE_URL: string;
            SUPABASE_ANON_KEY: string;
            SUPABASE_ACCOUNT_EMAIL: string;
            SUPABASE_ACCOUNT_PASSWORD: string;
        }
    }
}
