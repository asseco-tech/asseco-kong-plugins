return {
  name = "asseco-jwt-transformer",
  fields = {
    {
      config = {
        type = "record",
        fields = {
          {
            jwt_secret = {
              type = "string",
              required = true,
            },
          },
          {
            cloning_fields = {
              type = "array",
              elements = {
                type = "string",
              },
            },
          },
          {
            hashed_cloning_fields = {
              type = "array",
              elements = {
                type = "string",
              },
            },
          },
          {
            cloning_place = {
              type = "string",
              one_of = {
                "body",
                "header",
              },
              default = "body"
            }
          }
        },
      },
    },
  },
}
