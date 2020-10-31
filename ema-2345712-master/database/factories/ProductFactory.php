<?php

use App\Models\Product;
use App\Models\User;
use Faker\Generator as Faker;

$factory->define(Product::class, function (Faker $faker) {
    return [
        'name' => $name = $faker->unique()->name,
        'slug' => str_slug($name),
        'description' => $faker->sentence(5),
        'price' => 1000,
        'user_id' => factory(User::class)->create()->id
    ];
});
