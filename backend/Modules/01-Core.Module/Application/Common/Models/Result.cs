namespace Core.Module.Application.Common.Models
{
    public class Result<T>
    {
        public bool Succeeded { get; set; }
        public string Message { get; set; }
        public T Data { get; set; }
        public string[] Errors { get; set; }

        public static Result<T> Success(T data, string message = null)
        {
            return new Result<T>
            {
                Succeeded = true,
                Data = data,
                Message = message
            };
        }

        public static Result<T> Failure(string[] errors, string message = null)
        {
            return new Result<T>
            {
                Succeeded = false,
                Errors = errors,
                Message = message
            };
        }

        public static Result<T> Failure(string error, string message = null)
        {
            return new Result<T>
            {
                Succeeded = false,
                Errors = new[] { error },
                Message = message
            };
        }
    }

    public class Result
    {
        public bool Succeeded { get; set; }
        public string Message { get; set; }
        public string[] Errors { get; set; }

        public static Result Success(string message = null)
        {
            return new Result
            {
                Succeeded = true,
                Message = message
            };
        }

        public static Result Failure(string[] errors, string message = null)
        {
            return new Result
            {
                Succeeded = false,
                Errors = errors,
                Message = message
            };
        }

        public static Result Failure(string error, string message = null)
        {
            return new Result
            {
                Succeeded = false,
                Errors = new[] { error },
                Message = message
            };
        }
    }
}