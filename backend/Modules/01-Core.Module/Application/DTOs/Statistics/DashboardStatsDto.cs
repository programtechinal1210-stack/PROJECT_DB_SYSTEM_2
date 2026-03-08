namespace Core.Module.Application.DTOs.Statistics
{
    public class DashboardStatsDto
    {
        public int TotalUsers { get; set; }
        public int ActiveUsers { get; set; }
        public int InactiveUsers { get; set; }
        public int TotalRoles { get; set; }
        public int SystemRoles { get; set; }
        public int CustomRoles { get; set; }
        public int TotalPermissions { get; set; }
        public int ActiveSessions { get; set; }
        public List<RecentActivityDto> RecentActivities { get; set; }
        public List<UserGrowthDto> UserGrowth { get; set; }
        public List<PopularRoleDto> PopularRoles { get; set; }
    }

    public class RecentActivityDto
    {
        public string UserName { get; set; }
        public string Activity { get; set; }
        public DateTime Timestamp { get; set; }
        public string IpAddress { get; set; }
    }

    public class UserGrowthDto
    {
        public string Period { get; set; } // Day, Week, Month
        public int Count { get; set; }
    }

    public class PopularRoleDto
    {
        public string RoleName { get; set; }
        public int UserCount { get; set; }
        public double Percentage { get; set; }
    }
}