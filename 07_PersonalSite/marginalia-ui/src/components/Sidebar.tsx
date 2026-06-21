import { NavLink } from "react-router-dom";
import { BookOpen, House, MessageSquare, Search, Settings, Library } from "lucide-react";

import { APP_VERSION } from "@/lib/appVersion";
import { cn } from "@/lib/utils";
import { usePrefs } from "@/lib/prefs";
import { useI18n } from "@/lib/i18n";

interface Item {
  to: string;
  labelKey: "chat" | "library" | "search" | "settings";
  icon: typeof MessageSquare;
}

const ITEMS: Item[] = [
  { to: "/chat", labelKey: "chat", icon: MessageSquare },
  { to: "/library", labelKey: "library", icon: BookOpen },
  { to: "/search", labelKey: "search", icon: Search },
  { to: "/settings", labelKey: "settings", icon: Settings },
];

export function Sidebar() {
  const compact = usePrefs((s) => s.compactSidebar);
  const { t } = useI18n();
  return (
    <aside
      className={cn(
        "fixed inset-x-3 bottom-3 z-50 flex h-14 shrink-0 items-center rounded-lg border border-border bg-bg-subtle/95 px-2 shadow-[0_18px_45px_rgb(0_0_0_/_0.35)] backdrop-blur",
        "md:static md:inset-auto md:z-auto md:h-auto md:flex-col md:items-stretch md:rounded-none md:border-y-0 md:border-l-0 md:border-r md:bg-bg-subtle/90 md:px-0 md:shadow-none",
        compact ? "md:w-14" : "md:w-52",
      )}
    >
      <div className={cn(
        "hidden items-center gap-2 py-4 md:flex",
        compact ? "justify-center px-2" : "justify-center px-2 md:justify-start md:px-4",
      )}>
        <div className="flex h-8 w-8 items-center justify-center rounded-md bg-accent text-accent-fg">
          <Library size={18} strokeWidth={2.2} />
        </div>
        {!compact && (
          <div className="hidden flex-col leading-tight md:flex">
            <span className="text-sm font-semibold tracking-tight">{t.common.appName}</span>
            <span className="text-[11px] text-fg-subtle">{t.common.personalLibrary}</span>
          </div>
        )}
      </div>

      <nav className="flex flex-1 items-center justify-around gap-1 px-1 md:flex-none md:flex-col md:items-stretch md:justify-start md:px-2">
        <a
          href="/"
          title="YUSU 主页"
          className={cn(
            "flex h-10 w-10 items-center justify-center rounded-md text-sm text-fg-muted transition-colors hover:bg-bg-muted hover:text-fg-base md:mb-2 md:h-auto md:w-full md:border-b md:border-border",
            compact
              ? "md:px-2 md:py-2"
              : "md:justify-start md:gap-2.5 md:px-2.5 md:py-1.5",
          )}
        >
          <House size={16} strokeWidth={2} />
          {!compact && <span className="hidden md:inline">YUSU 主页</span>}
        </a>
        {ITEMS.map((it) => {
          const Icon = it.icon;
          const label = t.nav[it.labelKey];
          return (
            <NavLink
              key={it.to}
              to={it.to}
              title={label}
              className={({ isActive }) =>
                cn(
                  "flex h-10 w-10 items-center justify-center rounded-md text-sm transition-colors md:h-auto md:w-full",
                  "hover:bg-bg-muted",
                  compact
                    ? "md:px-2 md:py-2"
                    : "md:justify-start md:gap-2.5 md:px-2.5 md:py-1.5",
                  isActive
                    ? "bg-bg-muted text-fg-base font-medium"
                    : "text-fg-muted",
                )
              }
            >
              <Icon size={16} strokeWidth={2} />
              {!compact && <span className="hidden md:inline">{label}</span>}
            </NavLink>
          );
        })}
      </nav>

      {!compact && (
        <div className="mt-auto hidden px-4 py-3 text-[11px] text-fg-subtle md:block">
          v{APP_VERSION}
        </div>
      )}
    </aside>
  );
}
